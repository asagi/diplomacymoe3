class AddRegulationToTable < ActiveRecord::Migration[5.2]
  def change
    add_reference :tables, :regulation, foreign_key: true
  end
end
