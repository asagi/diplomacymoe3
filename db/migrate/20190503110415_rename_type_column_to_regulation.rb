class RenameTypeColumnToRegulation < ActiveRecord::Migration[5.2]
  def change
    rename_column :regulations, :type, :face_type
  end
end
