class AddFieldsToPower < ActiveRecord::Migration[5.2]
  def change
    add_column :powers, :symbol, :string
    add_column :powers, :name, :string
    add_column :powers, :genitive, :string
  end
end
