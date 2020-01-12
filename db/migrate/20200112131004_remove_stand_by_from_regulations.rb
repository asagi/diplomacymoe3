class RemoveStandByFromRegulations < ActiveRecord::Migration[5.2]
  def change
    remove_column :regulations, :stand_by, :boolean
  end
end
