class AddPowerToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :power, :string
  end
end
