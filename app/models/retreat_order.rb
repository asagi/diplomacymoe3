# frozen_string_literal: true

class RetreatOrder < Order
  def retreat?
    true
  end

  def to_s
    format(
      'Retreat %<kind>s %<prov>s-%<dest>s',
      kind: unit_kind,
      prov: unit.province,
      dest: dest
    ).gsub(/_(..)/, '(\1)')
  end
end
