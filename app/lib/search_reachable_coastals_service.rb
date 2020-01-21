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

    waters_with_fleet = @fleets.map(&:province)
    marked = reachable_waters(
      province: @unit.province,
      fleets: waters_with_fleet
    )
    if MapUtil.provinces[@unit.province]['type'] == Water.to_s
      marked << @unit.province
    end
    coastals = []
    marked.each do |water|
      MapUtil.adjacents[water].each do |k, _v|
        next if k[0, 3] == @unit.province
        next unless MapUtil.provinces[k]['type'] == Coastal.to_s

        coastals << k
      end
    end
    coastals -= MapUtil.adjacents[@unit.province]
                       .select { |_k, v| v['army'] }.keys
    coastals.map { |c| c[0, 3] }.uniq
  end

  def reachable_waters(province:, fleets:, marked: [])
    MapUtil.adjacents[province].each_key do |k|
      next if marked.include?(k)
      next unless fleets.include?(k)

      if MapUtil.provinces[k]['type'] == Water.to_s
        reachable_waters(province: k, fleets: fleets, marked: marked.push(k))
      end
    end
    marked
  end
end
