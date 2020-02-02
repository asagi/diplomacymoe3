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
    MapUtil.adjacents[@unit.prov_code].inject([]) do |result, (prov_code, data)|
      next result unless retreatable?(prov_code[0, 3], data)

      result << RetreatOrder.new(power: @power, unit: @unit, dest: prov_code)
    end
  end

  def retreatable?(prov_code, data)
    return false unless data[@unit.type.downcase]
    return false if @standoff.include?(prov_code)
    return false if @occupied_areas.include?(prov_code)
    return false if prov_code == @unit.keepout

    true
  end
end
