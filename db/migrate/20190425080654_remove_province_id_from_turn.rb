class RemoveProvinceIdFromTurn < ActiveRecord::Migration[5.2]
  def change
    remove_column :turns, :provinces_id, :string
  end
end
