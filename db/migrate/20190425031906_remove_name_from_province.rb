class RemoveNameFromProvince < ActiveRecord::Migration[5.2]
  def change
    remove_column :provinces, :name, :string
  end
end
