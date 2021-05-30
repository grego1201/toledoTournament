class AddPisteToPoule < ActiveRecord::Migration[6.1]
  def change
    add_column :poules, :piste, :integer
  end
end
