class AddPouleOrderToPoule < ActiveRecord::Migration[6.1]
  def change
    add_column :poules, :assault_order, :json
  end
end
