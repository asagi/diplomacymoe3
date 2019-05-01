class AddUnitsToTurn < ActiveRecord::Migration[5.2]
  def change
    add_reference :turns, :units, foreign_key: true
  end
end
