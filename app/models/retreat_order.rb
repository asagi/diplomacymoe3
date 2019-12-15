class RetreatOrder < Order
  def retreat?
    true
  end

  def to_s
    ("Retreat %s %s-%s" % [unit_kind, self.unit.province, self.dest]).gsub(/_(..)/, '(\1)')
  end
end
