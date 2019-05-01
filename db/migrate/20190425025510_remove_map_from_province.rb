class RemoveMapFromProvince < ActiveRecord::Migration[5.2]
  def change
    remove_column :provinces, :map_id, :string
  end
end
