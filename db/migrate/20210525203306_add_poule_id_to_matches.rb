class AddPouleIdToMatches < ActiveRecord::Migration[6.1]
  def change
    add_column :matches, :poule_id, :integer
    add_index  :matches, :poule_id
  end
end
