class RemoveTableFromMap < ActiveRecord::Migration[5.2]
  def change
    remove_reference :maps, :table, foreign_key: true
  end
end
