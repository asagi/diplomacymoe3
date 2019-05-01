class SupportOrder < Order
  def support?
    true
  end


  def to_s
    ("%s %s S %s"%[unit_kind, self.unit.province, formated_target]).gsub(/_(..)/, '(\1)')
  end
end
