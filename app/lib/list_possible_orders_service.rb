class ListPossibleOrdersService
  def self.call(turn:, power:, unit:)
    self.new(turn: turn, power: power, unit: unit).call
  end

  def initialize(turn:, power:, unit:)
    @turn = turn
    @power = power
    @unit = unit
    @dests = []
  end

  def call
    @orders = @turn.orders

    # HoldOrder
    holds = gen_hold_order_menu
    # MoveOrder
    moves = gen_move_order_menu
    # MoveOrderViaConvoy
    movcs = gen_movc_order_menu
    # SupportOrder
    supps = gen_supp_order_menu
    # ConvoyOrder
    convs = gen_conv_order_menu

    [holds, moves, movcs, supps, convs].reduce([], :concat)
  end

  def gen_hold_order_menu
    [HoldOrder.new(power: @power, unit: @unit)]
  end

  def gen_move_order_menu
    result = []
    GameMap.adjacents[@unit.province].each do |code, data|
      next unless data[@unit.type.downcase]
      result << MoveOrder.new(power: @power, unit: @unit, dest: code)
      @dests << code
    end
    result
  end

  def gen_movc_order_menu
    result = []
    return result unless @unit.army?
    return result unless GameMap.provinces[@unit.province]["type"] == Coastal.to_s
    SearchReachableCoastalsService.call(unit: @unit).each do |code|
      result << MoveOrder.new(power: @power, unit: @unit, dest: code)
    end
    result
  end

  def gen_supp_order_menu
    result = []
    @orders.each do |o|
      if !o.move? && @dests.map { |d| d[0, 3] }.include?(o.unit.province[0, 3])
        result << SupportOrder.new(power: @power, unit: @unit, target: o.to_key)
        next
      end

      if o.move? && @dests.map { |d| d[0, 3] }.include?(o.dest[0, 3])
        result << SupportOrder.new(power: @power, unit: @unit, target: o.to_key)
        next
      end
    end
    result
  end

  def gen_conv_order_menu
    result = []
    return [] unless GameMap.provinces[@unit.province]["type"] == Water.to_s
    @orders.where(type: MoveOrder.to_s).each do |o|
      coastals = SearchReachableCoastalsService.call(unit: @unit)
      next unless coastals.include?(o.unit.province)
      next unless coastals.include?(o.dest)
      result << ConvoyOrder.new(power: @power, unit: @unit, target: o.to_key)
    end
    result
  end
end
