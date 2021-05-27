class RemoveFencerSurname2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :fencers, :second_surname
  end
end
