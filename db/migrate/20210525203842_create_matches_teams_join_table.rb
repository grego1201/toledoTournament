class CreateMatchesTeamsJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :teams, :matches do |t|
      t.index :match_id
      t.index :team_id
    end
  end
end
