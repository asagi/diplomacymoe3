class CreateProvinces < ActiveRecord::Migration[5.2]
  def change
    create_table :provinces do |t|
      t.references :table, foreign_key: true
      t.references :map, foreign_key: true
      t.references :power, foreign_key: true

      t.timestamps
    end
  end
end
