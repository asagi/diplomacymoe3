class AddKeepoutToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :keepout, :string
  end
end
