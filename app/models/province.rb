# frozen_string_literal: true

class Province < ApplicationRecord
  belongs_to :turn

  def occupied_by(unit)
    self.power = unit.power.symbol
  end

  def occupied_by!(unit)
    self.power = unit.power.symbol
    save!
  end
end
