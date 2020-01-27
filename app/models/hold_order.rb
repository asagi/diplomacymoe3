# frozen_string_literal: true

class HoldOrder < Order
  def hold?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov>s H',
      kind: unit_kind,
      prov: unit.province
    ).gsub(/_(..)/, '(\1)')
  end
end
