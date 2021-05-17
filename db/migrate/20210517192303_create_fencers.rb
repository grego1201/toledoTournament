class CreateFencers < ActiveRecord::Migration[6.1]
  def change
    create_table :fencers do |t|
      t.string :name
      t.string :team
      t.string :nationality
      t.string :surname
      t.string :second_surname

      t.timestamps
    end
  end
end
