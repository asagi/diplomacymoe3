class RemoveTableIdFromProvince < ActiveRecord::Migration[5.2]
  def change
    remove_column :provinces, :table_id, :string
  end
end
