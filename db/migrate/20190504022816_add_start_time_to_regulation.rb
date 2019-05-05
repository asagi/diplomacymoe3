class AddStartTimeToRegulation < ActiveRecord::Migration[5.2]
  def change
    add_column :regulations, :start_time, :string
  end
end
