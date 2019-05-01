class CreateTurns < ActiveRecord::Migration[5.2]
  def change
    create_table :turns do |t|
      t.references :table, foreign_key: true
      t.integer :number

      t.timestamps
    end
  end
end
