class AddPhaseToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :phase, :integer
  end
end
