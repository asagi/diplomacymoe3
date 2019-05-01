class AddDestToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :dest, :string
  end
end
