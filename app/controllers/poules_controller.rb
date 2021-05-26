class PoulesController < ApplicationController
  def index
    @poules = Poule.all
  end

  def show
    @poule = Poule.find(params[:id])
    @poule_results = calculate_results_from_poule
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
        team_match_results(key, value),
        nil,
        team_statistics(key, value, @poule)
      ].flatten
    end
  end

  def team_match_results(team_id, values)
    values.keys.sort.map do |op_team_id|
      victory, points = values[op_team_id]

      victory_char = ''
      victory_char = 'V' if victory && points.to_i < 20
      "#{victory_char}#{points}"
    end
  end

  def team_statistics(team_id, values, poule)
    hit_points = 0
    values.each do |_, result|
      hit_points += result&.second || 0
    end

    received_points = 0
    poule.poule_matches.keys.each do |key|
      next if key == team_id
      received_points += poule.poule_matches[key][team_id]&.second || 0
    end

    victories = 0
    values.each do |_, result|
      victories += 1 if result&.first
    end

    victory_percent = victories == 0 ? 0 : victories/(values.count-1).to_f
    [victory_percent, hit_points - received_points, hit_points]
  end
end
