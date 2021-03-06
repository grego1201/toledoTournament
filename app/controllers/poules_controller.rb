class PoulesController < ApplicationController
  ASSAULT_ORDER = {
    "5" => ['1/2', '3/4', '5/1', '2/3', '4/5', '1/4', '2/5', '3/1', '3/5', '4/2'],
    "4" => ['1/4', '2/3', '1/3', '2/4', '3/4', '1/2'],
    "3" => ['2/1', '3/2', '1/3']
  }

  def index
    @poules = Poule.all.sort
    @all_poules = Poule.all || []
    @teams = Team.all
    @old_params = params.permit(:poule_id, :team_name)
    @poules = @poules.where(id: @old_params[:poule_id].to_i) unless @old_params[:poule_id].blank?
    @poules = @poules.joins(:teams).where("lower(teams.name) ILIKE ?", "%#{@old_params[:team_name].downcase}%") unless @old_params[:team_name].blank?

    @poules.sort
  end

  def show
    @poule = Poule.find(params[:id])
    @poule_results = calculate_results_from_poule
    @teams = @poule.teams.order(:id) || []
    @teams_for_select = @poule.teams.order(:id).collect {|team| ["#{team.fake_id} #{team.name}", team.id]}
  end

  def update
    @poule = Poule.find(params[:id])
    update_params = params.permit(:piste)

    if @poule.update(update_params)
      redirect_to @poule
    else
      render :show
    end
  end

  def classification
    @poules = Poule.all
    @classification = calculcate_classification
    @team_names_by_id = team_names_by_id
  end

  def export_classification_file
    @poules = Poule.all
    @classification = calculcate_classification
    @team_names_by_id = team_names_by_id

    classification_list_text = []
    @classification.each_with_index do |value|
      team = Team.find(value.first)
      classification_list_text << [team.name, team.fencer_names, value.second.join(' / ')]
    end

    file_path = "tmp/classification_#{Time.now.to_i}.pdf"

    Prawn::Document.generate(file_path) do
      bounding_box [25,cursor], :width => 600 do
        text "Posición. " + "Nombre equipo" + "-->" + "V/M / TD-TR / TD"
      end

      bounding_box [25,cursor], :width => 600 do
        text "Nombre tiradoras"
      end

      move_down(10)
      classification_list_text.each_with_index do |text, index|
        bounding_box [25,cursor], :width => 600 do
          text "#{index + 1}. " + text.first + "-->" + text.third
        end
        bounding_box [25,cursor], :width => 600 do
          text text.second
        end

        move_down(10)
      end
    end

    send_file(file_path)
  end

  def generate_random_poules
    Poule.destroy_all

    max_fencers_per_poule = params.require(:max_per_poule).to_i
    team_ids = Team.all.pluck(:id).shuffle

    total_teams = team_ids.count
    extra_fencers = total_teams % max_fencers_per_poule
    if extra_fencers.zero?
      group_of_ids = team_ids.in_groups_of(max_fencers_per_poule)
    else
      total_groups = (total_teams / max_fencers_per_poule) + 1
      group_of_ids = []

      total_groups.times do |i|
        group_of_ids[i] = []
      end

      team_ids.each_with_index do |team_id, index|
        group_of_ids[index % total_groups] << team_id
      end
    end

    group_of_ids.each do |teams|
      Poule.create(team_ids: teams)
    end

    generate_poule_matches
    generate_poule_assault_order

    redirect_to poules_path
  end

  def add_poule_result
    safe_params = params.permit(:poule_results, :team_id, :id)
    poule_id = safe_params[:id]
    poule = Poule.find(poule_id)
    poule_results = safe_params[:poule_results]
    team_id = safe_params[:team_id]

    poule_matches = poule.poule_matches[team_id]
    new_results = {}
    splitted_results = poule_results.split(',')
    poule_matches.keys.sort.each_with_index do |key, index|
      result = splitted_results[index].delete(' ')
      victory = result.upcase.include?('V') || result.to_i == 20
      new_results[key] = [victory, result.gsub(/[^0-9]/, '')]
    end

    poule.poule_matches.merge!({team_id.to_sym => new_results})
    poule.save

    redirect_to poule_path(poule_id)
  end

  def calculcate_classification
    team_results = {}
    Poule.all.each do |poule|
      poule.poule_matches.keys.each do |team_id|
        team_results[team_id] = team_statistics(team_id, poule.poule_matches[team_id], poule)
      end
    end

    team_results.to_a.sort_by { |k| [k[1][0], k[1][1], k[1][2]] }.reverse
  end

  private

  def generate_poule_matches
    Poule.all.each do |poule|
      team_ids = poule.teams.map(&:id)
      poule_matches = {}

      team_ids.sort.each do |team_id|
        poule_matches[team_id] = {}
        team_ids.sort.each do |other_team_id|
          next if team_id == other_team_id

          poule_matches[team_id][other_team_id] = nil
        end
      end

      poule.poule_matches = poule_matches
      poule.save
    end
  end

  def generate_poule_assault_order
    Poule.all.each do |poule|
      team_ids = poule.teams.map(&:id)
      order = ASSAULT_ORDER[team_ids.count.to_s]
      assaults_order = {}

      order.each_with_index do |teams, index|
        team_ids = teams.split('/')
        first_team = team_ids.sample
        second_team = (team_ids - [first_team]).first
        assaults_order[index + 1] = {
          first_team: first_team,
          second_team: second_team
        }
      end

      poule.assault_order = assaults_order
      poule.save
    end
  end

  def calculate_results_from_poule
    [].tap do |results|
      @poule.poule_matches.sort.to_h.each_with_index do |value, index|
        key, value = value
        results << [
          team_index_name(key),
          index + 1,
          team_match_results(key, value, @poule),
          nil,
          team_statistics(key, value, @poule)
        ].flatten
      end
    end
  end

  def team_match_results(team_id, values, poule)
    match_results = values.keys.sort.map do |op_team_id|
      victory, points = values[op_team_id]

      victory_char = ''
      victory_char = 'V' if victory && points.to_i < 20
      "#{victory_char}#{points}"
    end

    team_index = poule.team_ids.map(&:to_s).sort.find_index(team_id)
    match_results.insert(team_index, [nil])
  end

  def team_statistics(team_id, values, poule)
    hit_points = 0
    values.each do |_, result|
      hit_points += result&.second.to_i || 0
    end

    received_points = 0
    poule.poule_matches.keys.each do |key|
      next if key == team_id
      received_points += poule.poule_matches[key][team_id]&.second.to_i || 0
    end

    victories = 0
    values.each do |_, result|
      victories += 1 if result&.first
    end

    victory_percent = victories == 0 ? 0 : (victories/(values.count).to_f).round(3)
    [victory_percent, hit_points - received_points, hit_points]
  end

  def team_index_name(key)
    team = Team.find(key)
    "#{team.fake_id}. #{team.name}"
  end

  def team_names_by_id
    {}.tap do |names|
      Team.all.pluck(:id, :name).each do |id, name|
        names[id] = name
      end
    end
  end
end
