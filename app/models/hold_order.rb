# frozen_string_literal: true

class HoldOrder < Order
  def hold?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov_code>s H',
      kind: unit_kind,
      prov_code: unit.prov_code
    ).gsub(/_(..)/, '(\1)')
  end
end
