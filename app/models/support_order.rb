# frozen_string_literal: true

class SupportOrder < Order
  def support?
    true
  end

  def to_s
    format(
      '%s %s S %s',
      unit_kind,
      unit.province,
      formated_target
    ).gsub(/_(..)/, '(\1)')
  end
end
