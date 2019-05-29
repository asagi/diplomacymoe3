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

  def owner
    self.power.symbol
  end

  def kind
    self.type.to_s[0].downcase
  end
end
