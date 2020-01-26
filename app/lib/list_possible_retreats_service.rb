# frozen_string_literal: true

class ListPossibleRetreatsService
  def self.call(turn:, power:, unit:, standoff: [])
    new(turn: turn, power: power, unit: unit, standoff: standoff).call
  end

  def initialize(turn:, power:, unit:, standoff:)
    @turn = turn
    @power = power
    @unit = unit
    @standoff = standoff
  end

  def call
    @occupied_areas = @unit.turn.units
                           .where(phase: @unit.phase)
                           .map(&:prov_key)

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
    MapUtil.adjacents[@unit.province].inject([]) do |result, (prov, data)|
      next result unless retreatable?(prov[0, 3], data)

      result << RetreatOrder.new(power: @power, unit: @unit, dest: prov)
    end
  end

  def retreatable?(prov, data)
    return false unless data[@unit.type.downcase]
    return false if @standoff.include?(prov)
    return false if @occupied_areas.include?(prov)
    return false if prov == @unit.keepout

    true
  end
end
