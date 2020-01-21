# frozen_string_literal: true

class RetreatOrder < Order
  def retreat?
    true
  end

  def to_s
    format(
      'Retreat %s %s-%s',
      unit_kind,
      unit.province,
      dest
    ).gsub(/_(..)/, '(\1)')
  end
end
