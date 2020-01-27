# frozen_string_literal: true

class MoveOrder < Order
  def move?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov>s-%<dest>s',
      kind: unit_kind,
      prov: unit.province,
      dest: dest
    ).gsub(/_(..)/, '(\1)')
  end
end
