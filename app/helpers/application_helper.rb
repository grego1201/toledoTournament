module ApplicationHelper
  def team_name(team_id)
    team = Team.find(team_id)
    team.name || team.id
  end

  def team_fencer_names(team_id)
    team = Team.find(team_id)
    names = ""
    team.fencers.each do |fencer|
      names += "|| #{fencer.name} #{fencer.surname} - #{fencer.club} "
    end

    names
  end

  def calculate_results_from_poule(poule_id)
    poule = Poule.find(poule_id)
    poule.poule_matches.sort.to_h.map do |key, value|
      [
        team_index_name(key),
        nil,
        team_match_results(key, value, poule),
        nil,
        team_statistics(key, value, poule)
      ].flatten
    end
  end

  def team_index_name(key)
    team = Team.find(key)
    "#{team.id}. #{team.name}"
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

    victory_percent = victories == 0 ? 0 : victories/(values.count).to_f
    [victory_percent, hit_points - received_points, hit_points]
  end
end
