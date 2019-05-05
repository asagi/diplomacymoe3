class AddStandByToRegulation < ActiveRecord::Migration[5.2]
  def change
    add_column :regulations, :stand_by, :boolean
  end
end
