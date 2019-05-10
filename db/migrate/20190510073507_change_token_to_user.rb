class ChangeTokenToUser < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :token, :string, charset:'utf8', collation:'utf8_bin'
  end
end
