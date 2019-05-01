class AddJnameToPower < ActiveRecord::Migration[5.2]
  def change
    add_column :powers, :jname, :string
  end
end
