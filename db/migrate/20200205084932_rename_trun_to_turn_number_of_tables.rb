class RenameTrunToTurnNumberOfTables < ActiveRecord::Migration[5.2]
  def change
    rename_column :tables, :turn, :turn_number
  end
end
