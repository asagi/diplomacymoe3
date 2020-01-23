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
      province: @unit.province,
      fleets: @fleets.map(&:province)
    )
    # @unit が海上にいる（＝海軍）なら所在地を経路に追加
    waters << @unit.province if MapUtil.water?(@unit.province)

    coastals = reachable_coastals(
      province: @unit.province,
      waters: waters
    )

    coastals.map { |c| c[0, 3] }.uniq
  end

  def reachable_waters(province:, fleets:, waters: [])
    MapUtil.adjacents[province].each_key do |prov|
      next if waters.include?(prov)
      next unless fleets.include?(prov)
      next unless MapUtil.water?(prov)

      waters = reachable_waters(
        province: prov,
        fleets: fleets,
        waters: waters.push(prov)
      )
    end
    waters
  end

  def reachable_coastals(province:, waters:)
    coastals = []
    waters.each do |water|
      MapUtil.adjacents[water].each_key do |prov|
        next if prov[0, 3] == province
        next unless MapUtil.coastal?(prov)

        coastals << prov
      end
    end
    # 陸路で移動可能な海岸は除外
    coastals -= MapUtil.adjacents[province]
                       .select { |_k, v| v['army'] }.keys
  end
end
