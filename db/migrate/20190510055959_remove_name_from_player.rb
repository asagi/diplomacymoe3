class RemoveNameFromPlayer < ActiveRecord::Migration[5.2]
  def change
    remove_column :players, :name, :string
  end
end
