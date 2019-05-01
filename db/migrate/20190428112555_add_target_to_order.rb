class AddTargetToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :target, :string
  end
end
