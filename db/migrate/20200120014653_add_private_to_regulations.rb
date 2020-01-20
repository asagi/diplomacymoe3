class AddPrivateToRegulations < ActiveRecord::Migration[5.2]
  def change
    add_column :regulations, :private, :boolean, default: false
  end
end
