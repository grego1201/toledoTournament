class EliminationGroupsController < ApplicationController
  def index
    @groups = EliminationGroup.all
  end

  def generate
    EliminationGroup.destroy_all
    classification = PoulesController.new.calculcate_classification
    groups = classification.in_groups(3, false)

    groups.each do |group|
      EliminationGroup.create(team_ids: group.map(&:first))
    end

    redirect_to elimination_groups_path
  end
end
