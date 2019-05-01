class AddTurnToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :turn, :integer
    add_column :tables, :phase, :integer
  end
end
