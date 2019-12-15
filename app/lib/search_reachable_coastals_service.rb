class SearchReachableCoastalsService
  def self.call(unit:, fleets: nil)
    self.new(unit: unit, fleets: fleets).call
  end

  def initialize(unit:, fleets:)
    @unit = unit
    @fleets = fleets ? fleets : @unit.turn.units.where(phase: @unit.phase).where(type: Fleet.to_s)
  end

  def call
    return [] if @fleets.empty?
    waters_with_fleet = @fleets.map { |f| f.province }
    marked = reachable_waters(province: @unit.province, fleets: waters_with_fleet)
    marked << @unit.province if Map.provinces[@unit.province]["type"] == Water.to_s
    coastals = []
    marked.each do |water|
      Map.adjacents[water].each do |k, v|
        next if k[0, 3] == @unit.province
        next unless Map.provinces[k]["type"] == Coastal.to_s
        coastals << k
      end
    end
    coastals -= Map.adjacents[@unit.province].select { |k, v| v["army"] }.keys
    coastals.map { |c| c[0, 3] }.uniq
  end

  def reachable_waters(province:, fleets:, marked: [])
    Map.adjacents[province].each_key do |k|
      next if marked.include?(k)
      next unless fleets.include?(k)
      if Map.provinces[k]["type"] == Water.to_s
        reachable_waters(province: k, fleets: fleets, marked: marked.push(k))
      end
    end
    marked
  end
end
