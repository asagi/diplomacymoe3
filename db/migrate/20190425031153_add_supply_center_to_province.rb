class AddSupplyCenterToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :supplycenter, :boolean
  end
end
