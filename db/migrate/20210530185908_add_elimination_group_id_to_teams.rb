class AddEliminationGroupIdToTeams < ActiveRecord::Migration[6.1]
  def change
    add_column :teams, :elimination_group_id, :integer
    add_index  :teams, :elimination_group_id
  end
end
