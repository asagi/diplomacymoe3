class ChangeColumnToUnit < ActiveRecord::Migration[5.2]
  def change
    remove_column :units, :power, :string
    add_column :units, :power_id, :bigint
    add_index :units, :power_id
  end
end
