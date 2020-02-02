class RenameProvinceToProvCodeInUnits < ActiveRecord::Migration[5.2]
  def change
    rename_column :units, :province, :prov_code
  end
end
