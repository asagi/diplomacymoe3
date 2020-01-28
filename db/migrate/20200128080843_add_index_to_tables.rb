class AddIndexToTables < ActiveRecord::Migration[5.2]
  def change
    add_index :tables, :number, unique: true
  end
end
