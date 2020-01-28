class AddNumberToTable < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :number, :integer
  end
end
