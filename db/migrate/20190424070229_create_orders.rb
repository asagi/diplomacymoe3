class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :turn, foreign_key: true
      t.references :power, foreign_key: true
      t.string :type

      t.timestamps
    end
  end
end
