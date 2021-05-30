class AddTableuToEliminationGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :elimination_groups, :tableaus, :json
  end
end
