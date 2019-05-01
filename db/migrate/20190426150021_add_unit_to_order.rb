class AddUnitToOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :unit, foreign_key: true
  end
end
