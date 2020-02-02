# frozen_string_literal: true

class PrioritizeDisbandingService
  def self.call(table:, power:)
    new(table: table, power: power).call
  end

  def initialize(table:, power:)
    @table = table
    @power = power
  end

  def call
    # ユニット毎に本国の一番近い補給都市への距離を計算
    units = @table.last_phase_units.where(power: @power)
    result = units.inject([]) do |nearest_supply_center, unit|
      supply_centers = home_suuply_centers_for(unit)
      supply_centers.sort! { |a, b| a[0] <=> b[0] }
      nearest_supply_center << supply_centers.first
    end
    sort_by_disassembly_priority(result)
  end

  def home_suuply_centers_for(unit)
    MapUtil.home_sc_codes(power: @power.symbol).map do |sc|
      [
        MapUtil.distance(start: sc, to: unit.prov_code),
        unit.type,
        MapUtil.prov_list[unit.prov_code]['name'],
        unit.prov_code
      ]
    end
  end

  def sort_by_disassembly_priority(distances_of_units)
    distances_of_units
      .sort { |a, b| a[2] <=> b[2] }  # ユニット駐留地域名アルファベット順
      .sort { |a, b| b[1] <=> a[1] }  # 海軍優先
      .sort { |a, b| b[0] <=> a[0] }  # 本国の一番近い補給都市への距離が遠い順
      .map { |x| x[3] }               # 港除去
      .uniq
  end
end
