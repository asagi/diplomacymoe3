class AddStatusToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :status, :integer
  end
end
