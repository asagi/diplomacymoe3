class Power < ApplicationRecord
  belongs_to :table
  has_one :player
  has_many :units

  A = 'a'
  E = 'e'
  F = 'f'
  G = 'g'
  I = 'i'
  R = 'r'
  T = 't'
  X = 'x'

  def supply_centers
    table.last_turn.provinces.where(power: self.symbol).where(supplycenter: true)
  end
end
