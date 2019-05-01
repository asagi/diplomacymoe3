class AddCodeToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :code, :string
  end
end
