class CreateEliminationGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :elimination_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
