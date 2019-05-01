class AddProvinceToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :province, :string
  end
end
