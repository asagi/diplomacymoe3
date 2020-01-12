class AddJugglingToRegulation < ActiveRecord::Migration[5.2]
  def change
    add_column :regulations, :juggling, :integer
  end
end
