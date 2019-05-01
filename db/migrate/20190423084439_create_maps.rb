class CreateMaps < ActiveRecord::Migration[5.2]
  def change
    create_table :maps do |t|
      t.references :table, foreign_key: true

      t.timestamps
    end
  end
end
