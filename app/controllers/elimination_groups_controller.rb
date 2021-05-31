class EliminationGroupsController < ApplicationController
  def index
    @groups = EliminationGroup.all
  end

  def show
    @group = EliminationGroup.find(params[:id])
    @tableau_size = [8, 4, 2, 1]
    @positions = [*1..8]
    @team_ids = @group.team_ids
  end

  def add_group_result
    @group = EliminationGroup.find(params[:id])

    safe_params = params.permit(:tableau, :position, :team_id)
    old_tableaus = @group.tableaus
    old_tableau = old_tableaus[safe_params[:tableau]] || {}
    old_tableau[safe_params[:position]] = safe_params[:team_id]

    @group.tableaus.merge!({safe_params[safe_params[:tableau]] => old_tableau})
    @group.save

    redirect_to @group
  end

  def generate
    EliminationGroup.destroy_all
    classification = PoulesController.new.calculcate_classification
    groups = classification.in_groups(3, false)
    full_size_tableaus = [2, 4, 8, 16, 32, 64, 128, 256]

    groups.each do |group|
      team_ids = group.map(&:first)
      tableau_size = Math.log2(team_ids.count).floor
      tableau_size +=1 unless full_size_tableaus.include?(tableau_size)
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
