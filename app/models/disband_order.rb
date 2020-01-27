# frozen_string_literal: true

class DisbandOrder < Order
  def disband?
    true
  end

  def to_s
    format(
      'Disband %<kind>s %<prov>s',
      kind: unit_kind,
      prov: unit.province
    ).gsub(/_(..)/, '(\1)')
  end
end
