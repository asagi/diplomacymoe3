# frozen_string_literal: true

class HoldOrder < Order
  def hold?
    true
  end

  def to_s
    format('%s %s H', unit_kind, unit.province).gsub(/_(..)/, '(\1)')
  end
end
