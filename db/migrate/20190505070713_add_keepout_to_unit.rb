class AddKeepoutToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :keepout, :string
  end
end
