class AddTurnToMap < ActiveRecord::Migration[5.2]
  def change
    add_reference :maps, :turn, foreign_key: true
  end
end
