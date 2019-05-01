class RemovePowerIdFromProvince < ActiveRecord::Migration[5.2]
  def change
    remove_column :provinces, :power_id, :string
  end
end
