# frozen_string_literal: true

class RetreatOrder < Order
  def retreat?
    true
  end

  def to_s
    format(
      'Retreat %<kind>s %<prov_code>s-%<dest>s',
      kind: unit_kind,
      prov_code: unit.prov_code,
      dest: dest
    ).gsub(/_(..)/, '(\1)')
  end
end
