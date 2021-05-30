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
end
