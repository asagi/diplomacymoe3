class RemoveMapIdFromTurn < ActiveRecord::Migration[5.2]
  def change
    remove_column :turns, :map_id, :string
  end
end
