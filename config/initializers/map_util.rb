# frozen_string_literal: true

class MapUtil < Settingslogic
  source Rails.root.join('config', 'map.yml')
  namespace Rails.env

  def self.water?(prov_code)
    prov_list[prov_code]['type'] == Water.to_s
  end

  def self.coastal?(prov_code)
    prov_list[prov_code]['type'] == Coastal.to_s
  end

  def self.max_provinces
    prov_list.count { |k, _v| k.length == 3 }
  end

  def self.distance(start:, to:)
    return 0 if to == start

    distances = { start => 0 }
    distances = calc_distance(current: start, to: to, distances: distances)
    distances[to]
  end

  def self.home_sc_codes(power:)
    prov_list
      .select { |_n, p| p['supplycenter'] }
      .select { |_n, p| p['owner'] == power }.keys
  end

  def self.update_shortest_distance_from_start(current:, distances:)
    adjacencies[current].each_key do |prov_code|
      distances[prov_code] ||= max_provinces
      distances[prov_code] = [distances[prov_code], distances[current] + 1].min
    end
    distances
  end

  def self.adjacencies_farther_from_start(current:, distances:)
    distances = update_shortest_distance_from_start(
      current: current,
      distances: distances
    )
    adjacencies[current]
      .select { |prov_code, _data| distances[prov_code] > distances[current] }
      .map { |prov_code, _data| prov_code }
  end

  def self.calc_distance(current:, to:, distances:, depth: 0)
    return distances if (distances[to] || max_provinces) < depth

    adjacencies = adjacencies_farther_from_start(
      current: current,
      distances: distances
    )
    adjacencies.each do |prov_code|
      calc_distance(
        current: prov_code,
        to: to,
        distances: distances,
        depth: depth + 1
      )
    end
    distances
  end
end
