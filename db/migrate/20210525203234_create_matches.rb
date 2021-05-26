class CreateMatches < ActiveRecord::Migration[6.1]
  def change
    create_table :matches do |t|
      t.integer :max_points
      t.integer :points_team_1
      t.integer :points_team_2
      t.string :notes

      t.timestamps
    end
  end
end
