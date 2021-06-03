class AddFinalClassificationToEliminationGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :elimination_groups, :final_classification, :json
  end
end
