class PrioritizeDisbandingService
  def self.call(table:, power:)
    self.new(table: table, power: power).call
  end

  def initialize(table:, power:)
    @table = table
    @power = power
  end

  def call
    result = []

    # ユニット毎に本国の一番近い補給都市への距離を計算
    units = @table.last_phase_units.where(power: @power)
    units.each do |unit|
      unit_distances = []
      home_sc = MapUtil.home_sc_codes(power: @power.symbol)
      home_sc.each do |sc|
        distance = MapUtil.distance(from: sc, to: unit.province)
        utype = unit.type
        pname = MapUtil.provinces[unit.province]["name"]
        unit_distances << [distance, utype, pname, unit.province]
      end
      unit_distances.sort! { |a, b| a[0] <=> b[0] }
      result << unit_distances.first
    end

    # ユニット駐留地域名アルファベット順
    result.sort! { |a, b| a[2] <=> b[2] }
    # 海軍優先
    result.sort! { |a, b| b[1] <=> a[1] }
    # 本国の一番近い補給都市への距離が遠い順
    result.sort! { |a, b| b[0] <=> a[0] }

    result = result.map { |x| x[3] }
    result.uniq!
    result
  end
end
