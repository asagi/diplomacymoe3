class Power < ApplicationRecord
  belongs_to :table
  has_one :player

  A = 'a'
  E = 'e'
  F = 'f'
  G = 'g'
  I = 'i'
  R = 'r'
  T = 't'
  X = 'x'
end
