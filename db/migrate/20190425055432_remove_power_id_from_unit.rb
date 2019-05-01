class RemovePowerIdFromUnit < ActiveRecord::Migration[5.2]
  def change
    remove_column :units, :power_id, :string
  end
end
