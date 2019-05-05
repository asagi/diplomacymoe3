class AddLastNegotiationPeriodToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :last_nego_period, :datetime
  end
end
