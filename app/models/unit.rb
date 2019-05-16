class Unit < ApplicationRecord
  belongs_to :turn
  belongs_to :power
  has_many :orders

  def army?
    false
  end

  def fleet?
    false
  end
end
