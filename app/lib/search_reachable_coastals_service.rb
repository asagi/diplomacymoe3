# frozen_string_literal: true

class SearchReachableCoastalsService
  def self.call(unit:, fleets: nil)
    new(unit: unit, fleets: fleets).call
  end

  def initialize(unit:, fleets:)
    @unit = unit
    @fleets = fleets || @unit.turn.units
                             .where(phase: @unit.phase)
                             .where(type: Fleet.to_s)
  end

  def call
    return [] if @fleets.empty?

    waters = reachable_waters(
      prov_code: @unit.prov_code,
      fleets: @fleets.map(&:prov_code)
    )
    # @unit が海上にいる（＝海軍）なら所在地を経路に追加
    waters << @unit.prov_code if MapUtil.water?(@unit.prov_code)

    coastals = reachable_coastals(
      prov_code: @unit.prov_code,
      waters: waters
    )
    coastals.map { |c| c[0, 3] }.uniq
  end

  def reachable_waters(prov_code:, fleets:, waters: [])
    MapUtil.adjacents[prov_code].each_key do |code|
      next if waters.include?(code)
      next unless fleets.include?(code)
      next unless MapUtil.water?(code)

      waters = reachable_waters(
        prov_code: code,
        fleets: fleets,
        waters: waters.push(code)
      )
    end
    waters
  end

  def reachable_coastals(prov_code:, waters:)
    coastals = []
    waters.each do |water|
      MapUtil.adjacents[water].each_key do |code|
        next if code[0, 3] == prov_code
        next unless MapUtil.coastal?(code)

        coastals << code
      end
    end
    # 陸路で移動可能な海岸は除外
    coastals -= MapUtil.adjacents[prov_code]
                       .select { |_k, v| v['army'] }.keys
  end
end
