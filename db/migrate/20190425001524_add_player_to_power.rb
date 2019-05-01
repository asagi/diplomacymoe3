class AddPlayerToPower < ActiveRecord::Migration[5.2]
  def change
    add_reference :powers, :player, foreign_key: true
  end
end
