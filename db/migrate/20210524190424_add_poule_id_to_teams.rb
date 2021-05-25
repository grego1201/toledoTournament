class AddPouleIdToTeams < ActiveRecord::Migration[6.1]
  def change
    add_column :teams, :poule_id, :integer
    add_index  :teams, :poule_id
  end
end
