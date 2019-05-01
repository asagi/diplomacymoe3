class RemoveUnitsIdFromTurn < ActiveRecord::Migration[5.2]
  def change
    remove_column :turns, :units_id, :string
  end
end
