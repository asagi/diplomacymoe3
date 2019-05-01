class Unit < ApplicationRecord
  belongs_to :turn

  def army?
    false
  end

  def fleet?
    false
  end
end
