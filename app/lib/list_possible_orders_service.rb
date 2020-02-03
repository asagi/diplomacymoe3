# frozen_string_literal: true

class ListPossibleOrdersService
  def self.call(turn:, power:, unit:)
    new(turn: turn, power: power, unit: unit).call
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
    MapUtil.adjacencies[@unit.prov_code].each do |code, data|
      next unless data[@unit.type.downcase]

      result << MoveOrder.new(power: @power, unit: @unit, dest: code)
      @dests << code
    end
    result
  end

  def gen_movc_order_menu
    result = []
    return result unless @unit.army?

    return result unless MapUtil.coastal?(@unit.prov_code)

    SearchReachableCoastalsService.call(unit: @unit).each do |prov_code|
      result << MoveOrder.new(power: @power, unit: @unit, dest: prov_code)
    end
    result
  end

  def gen_supp_order_menu
    @orders.each_with_object([]) do |order, result|
      if (supp = gen_supp_order_for_hold(order))
        next result << supp
      end
      if (supp = gen_supp_order_for_move(order))
        next result << supp
      end
    end
  end

  def gen_supp_order_for_hold(order)
    return if order.move?
    return unless @dests.map { |d| d[0, 3] }.include?(order.from[0, 3])

    SupportOrder.new(power: @power, unit: @unit, target: order.to_key)
  end

  def gen_supp_order_for_move(order)
    return unless order.move?
    return unless @dests.map { |d| d[0, 3] }.include?(order.dest[0, 3])

    SupportOrder.new(power: @power, unit: @unit, target: order.to_key)
  end

  def gen_conv_order_menu
    return [] unless MapUtil.water?(@unit.prov_code)

    @orders.where(type: MoveOrder.to_s).inject([]) do |result, o|
      coastals = SearchReachableCoastalsService.call(unit: @unit)
      next result unless coastals.include?(o.unit.prov_code)
      next result unless coastals.include?(o.dest)

      result << ConvoyOrder.new(power: @power, unit: @unit, target: o.to_key)
    end
  end
end
