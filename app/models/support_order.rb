# frozen_string_literal: true

class SupportOrder < Order
  def support?
    true
  end

  def to_s
    format(
      '%<kind>s %<prov_code>s S %<target>s',
      kind: unit_kind,
      prov_code: unit.prov_code,
      target: formated_target
    ).gsub(/_(..)/, '(\1)')
  end
end
