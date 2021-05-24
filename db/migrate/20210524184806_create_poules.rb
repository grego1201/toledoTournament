class CreatePoules < ActiveRecord::Migration[6.1]
  def change
    create_table :poules do |t|

      t.timestamps
    end
  end
end
