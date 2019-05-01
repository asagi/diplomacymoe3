class AddTurnToProvince < ActiveRecord::Migration[5.2]
  def change
    add_reference :provinces, :turn, foreign_key: true
  end
end
