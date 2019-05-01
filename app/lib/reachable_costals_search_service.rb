class ReachableCostalsSearchService
  def self.call(unit:, fleets: nil)
    self.new(unit: unit, fleets: fleets).call
  end


  def initialize(unit:, fleets:)
    @unit = unit
    @fleets = fleets ? fleets : @unit.turn.units.where(phase: @unit.phase).where(type: Fleet.to_s)
  end


  def call
    return [] if @fleets.empty?
    waters_with_fleet = @fleets.map{|f| f.province}
    marked = reachable_waters(province: @unit.province, fleets: waters_with_fleet)
    marked << @unit.province if Master.provinces[@unit.province]['type'] == Water.to_s
    coastals = []
    marked.each do |water|
      Master.adjacent_provinces[water].each do |k, v|
        next if k[0,3] == @unit.province
        next unless Master.provinces[k]['type'] == Coastal.to_s
        coastals << k
      end
    end
    coastals -= Master.adjacent_provinces[@unit.province].select{|k,v| v['army']}.keys
    coastals.map{|c| c[0,3]}.uniq
  end


  def reachable_waters(province:, fleets:, marked: [])
    Master.adjacent_provinces[province].each_key do |k|
      next if marked.include?(k)
      next unless fleets.include?(k)
      if Master.provinces[k]['type'] == Water.to_s
        reachable_waters(province: k, fleets: fleets, marked: marked.push(k))
      end
    end
    marked
  end
end
