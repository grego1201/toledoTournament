class PoulesController < ApplicationController
  def index
    @poules = Poule.all
    @classification = calculcate_classification
  end

  def show
    @poule = Poule.find(params[:id])
    @poule_results = calculate_results_from_poule
    @teams = @poule.teams
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
      victory = result.include?('V') || result.to_i == 20
      new_results[key] = [victory, result]
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

  def calculate_results_from_poule
    @poule.poule_matches.sort.to_h.map do |key, value|
      [
        key,
        nil,
        team_match_results(key, value, @poule),
        nil,
        team_statistics(key, value, @poule)
      ].flatten
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
    match_results.insert(team_index, [nil, nil])
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

    victory_percent = victories == 0 ? 0 : victories/(values.count-1).to_f
    [victory_percent, hit_points - received_points, hit_points]
  end
end
