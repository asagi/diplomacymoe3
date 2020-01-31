class AddOwnerToTable < ActiveRecord::Migration[5.2]
  def change
    add_reference :tables, :owner, foreign_key: { to_table: :users }
  end
end
