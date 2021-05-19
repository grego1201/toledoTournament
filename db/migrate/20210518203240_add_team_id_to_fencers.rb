class AddTeamIdToFencers < ActiveRecord::Migration[6.1]
  def change
    add_column :fencers, :team_id, :integer
    add_index  :fencers, :team_id
  end
end
