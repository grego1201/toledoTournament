class PoulesController < ApplicationController
  def index
    @poules = Poule.all
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

      team_ids.each do |team_id|
        poule_matches[team_id] = {}
        team_ids.each do |other_team_id|
          next if team_id == other_team_id

          poule_matches[team_id][other_team_id] = nil
        end
      end

      poule.poule_matches = poule_matches
      poule.save
    end
  end
end
