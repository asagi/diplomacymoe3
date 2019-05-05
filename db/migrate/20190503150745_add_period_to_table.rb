class AddPeriodToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :period, :datetime
  end
end
