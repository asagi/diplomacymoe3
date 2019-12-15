class DisbandOrder < Order
  def disband?
    true
  end

  def to_s
    ("Disband %s %s" % [unit_kind, self.unit.province]).gsub(/_(..)/, '(\1)')
  end
end
