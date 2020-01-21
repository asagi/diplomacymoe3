# frozen_string_literal: true

class MoveOrder < Order
  def move?
    true
  end

  def to_s
    format('%s %s-%s', unit_kind, unit.province, dest).gsub(/_(..)/, '(\1)')
  end
end
