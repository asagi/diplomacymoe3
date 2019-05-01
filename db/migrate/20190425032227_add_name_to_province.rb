class AddNameToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :name, :string
  end
end
