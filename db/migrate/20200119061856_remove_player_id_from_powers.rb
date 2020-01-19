class RemovePlayerIdFromPowers < ActiveRecord::Migration[5.2]
  def change
    remove_column :powers, :player_id
  end
end
