class ListPossibleRetreatsService
  def self.call(turn:, power:, unit:, standoff: [])
    self.new(turn: turn, power: power, unit: unit, standoff: standoff).call
  end

  def initialize(turn:, power:, unit:, standoff:)
    @turn = turn
    @power = power
    @unit = unit
    @standoff = standoff
  end

  def call
    @occupied_areas = @unit.turn.units.where(phase: @unit.phase).map { |u| u.province[0, 3] }

    # DisbandOrder
    disband = gen_disband_order_menu
    # RetreatOrder
    retreats = gen_retreat_order_menu

    [disband, retreats].reduce([], :concat)
  end

  def gen_disband_order_menu
    [DisbandOrder.new(power: @power, unit: @unit)]
  end

  def gen_retreat_order_menu
    result = []
    MapUtil.adjacents[@unit.province].each do |code, data|
      next unless data[@unit.type.downcase]
      next if @standoff.include?(code[0, 3])
      next if @occupied_areas.include?(code[0, 3])
      next if code[0, 3] == @unit.keepout[0, 3]
      result << RetreatOrder.new(power: @power, unit: @unit, dest: code)
    end
    result
  end
end
