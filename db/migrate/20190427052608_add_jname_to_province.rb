class AddJnameToProvince < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :jname, :string
  end
end
