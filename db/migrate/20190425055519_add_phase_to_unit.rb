class AddPhaseToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :phase, :integer
  end
end
