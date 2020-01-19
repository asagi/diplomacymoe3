class AddDesiredPowerToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :desired_power, :string
  end
end
