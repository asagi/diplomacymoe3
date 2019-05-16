class AddPowerToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_reference :players, :power, foreign_key: true
  end
end
