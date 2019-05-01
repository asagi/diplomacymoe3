class RemoveFullnameFromProvince < ActiveRecord::Migration[5.2]
  def change
    remove_column :provinces, :fullname, :string
  end
end
