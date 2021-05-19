class RenameFencerTeamToClub < ActiveRecord::Migration[6.1]
  def change
    rename_column :fencers, :team, :club
  end
end
