class EliminationGroupsController < ApplicationController
  def index
    @groups = EliminationGroup.all
  end

  def generate
    EliminationGroup.destroy_all
    classification = PoulesController.new.calculcate_classification
    groups = classification.in_groups(3, false)
    full_size_tableaus = [2, 4, 8, 16, 32, 64, 128, 256]

    groups.each do |group|
      team_ids = group.map(&:first)
      tableau_size = Math.log2(team_ids.count).floor
      tableau_size +=1 if full_size_tableaus.include?(tableau_size)
      tableau_size = 2**(tableau_size)

      tableau_teams = {}
      team_ids.each_with_index do |team_id, index|
        tableau_teams[index + 1] = team_id
      end

      tableau_positions = {}
      tableau_positions[tableau_size] = tableau_teams

      EliminationGroup.create(team_ids: team_ids, tableaus: tableau_positions)
    end

    redirect_to elimination_groups_path
  end
end
