class HoldOrder < Order
  def hold?
    true
  end


  def to_s
    ("%s %s H"%[unit_kind, self.unit.province]).gsub(/_(..)/, '(\1)')
  end
end
