class CreateRegulations < ActiveRecord::Migration[5.2]
  def change
    create_table :regulations do |t|
      t.integer :type
      t.integer :period_rule
      t.integer :duration
      t.string :keyword

      t.timestamps
    end
  end
end
