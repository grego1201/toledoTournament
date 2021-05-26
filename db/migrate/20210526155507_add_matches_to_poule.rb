class AddMatchesToPoule < ActiveRecord::Migration[6.1]
  def change
    add_column :poules, :poule_matches, :json
  end
end
