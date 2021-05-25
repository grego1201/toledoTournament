class PoulesController < ApplicationController
  def index
    @poules = Poule.all
  end

  def generate_random_poules
    Poule.destroy_all

    max_fencers_per_poule = params.require(:max_per_poule).to_i
    team_ids = Team.all.pluck(:id).shuffle

    total_teams = team_ids.count
    if (total_teams % max_fencers_per_poule).zero?
      group_of_ids = team_ids.in_groups_of(max_fencers_per_poule)
    else
      group_of_ids = team_ids.in_groups_of(max_fencers_per_poule - 1)
      group_of_ids.last.each_with_index do |team_id, index|
        next if team_id.nil?
        group_of_ids[index] = group_of_ids[index] + [team_id]
      end

      group_of_ids.pop
    end

    group_of_ids.each do |teams|
      Poule.create(team_ids: teams)
    end

    redirect_to poules_path
  end
end
