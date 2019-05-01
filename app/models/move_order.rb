class MoveOrder < Order
  def move?
    true
  end


  def to_s
    ("%s %s-%s"%[unit_kind, self.unit.province, self.dest]).gsub(/_(..)/, '(\1)')
  end
end
