class Map < Settingslogic
  source Rails.root.join('config', 'map.yml');
  namespace Rails.env

  def self.max_provinces
    provinces.count{|k,v| k.length == 3}
  end


  def self.distance(from:, to:)
    return 0 if to.include?(from)
    distances = {from => 0}
    calc_distance(from: from, to: to, distances: distances)
    distances[to]
  end


  private
  def self.calc_distance(from:, to:, distances:, depth: 0)
    return if (distances[to] || max_provinces) < depth
    adjacents[from].each do |prov, data|
      distances[prov] ||= max_provinces
      distances[prov] = [ distances[prov], distances[from] + 1 ].min
    end
    adjacents[from].select{|prov, data| distances[prov] > distances[from]}.each do |prov, data|
      calc_distance(from: prov, to: to, distances: distances, depth: depth + 1)
    end
  end
end
