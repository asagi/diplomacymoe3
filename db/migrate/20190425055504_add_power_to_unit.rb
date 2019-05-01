class AddPowerToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :power, :string
  end
end
