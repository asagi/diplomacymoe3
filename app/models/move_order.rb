# frozen_string_literal: true

class MoveOrder < Order
  def move?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov_code>s-%<dest>s',
      kind: unit_kind,
      prov_code: unit.prov_code,
      dest: dest
    ).gsub(/_(..)/, '(\1)')
  end
end
