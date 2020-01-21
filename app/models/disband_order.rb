# frozen_string_literal: true

class DisbandOrder < Order
  def disband?
    true
  end

  def to_s
    format('Disband %s %s', unit_kind, unit.province).gsub(/_(..)/, '(\1)')
  end
end
