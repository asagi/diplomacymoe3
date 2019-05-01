class AddMapToTurn < ActiveRecord::Migration[5.2]
  def change
    add_reference :turns, :map, foreign_key: true
  end
end
