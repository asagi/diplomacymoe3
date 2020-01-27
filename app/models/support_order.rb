# frozen_string_literal: true

class SupportOrder < Order
  def support?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov>s S %<target>s',
      kind: unit_kind,
      prov: unit.province,
      target: formated_target
    ).gsub(/_(..)/, '(\1)')
  end
end
