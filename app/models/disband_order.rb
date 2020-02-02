# frozen_string_literal: true

class DisbandOrder < Order
  def disband?
    true
  end

  def to_s
    format(
      'Disband %<kind>s %<prov_code>s',
      kind: unit_kind,
      prov_code: unit.prov_code
    ).gsub(/_(..)/, '(\1)')
  end
end
