class AddTypeToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :type, :string
  end
end
