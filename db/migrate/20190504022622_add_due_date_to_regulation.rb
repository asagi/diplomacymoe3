class AddDueDateToRegulation < ActiveRecord::Migration[5.2]
  def change
    add_column :regulations, :due_date, :date
  end
end
