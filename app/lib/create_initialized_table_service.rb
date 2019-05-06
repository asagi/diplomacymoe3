class CreateInitializedTableService
  def self.call(regulation: nil)
    regulation = Regulation.create unless regulation
    self.new(regulation: regulation).call
  end


  def initialize(regulation:)
    @regulation = regulation
  end


  def call
    table = Table.create(turn: Const.turns.initial, phase: Const.phases.final, regulation: @regulation)
    table = setup_powers(table)
    table = setup_initial_turn(table)
    table.period = @regulation.first_period if @regulation
    table.save!
    table
  end


  private
  def setup_powers(table)
    # 国
    Initial.powers.each do |symbol, data|
      params = {}
      params['symbol'] = symbol
      params['name'] = data['name']
      params['jname'] = data['jname']
      params['genitive'] = data['genitive']
      table.powers.build(params)
    end
    table
  end


  def setup_initial_turn(table)
    # 開幕ターン
    turn = table.turns.build

    Map.provinces.each do |code, province|
      next unless province['owner']
      params = {}
      params['code'] = code
      params['type'] = province['type']
      params['name'] = province['name']
      params['supplycenter'] = !!province['supplycenter']
      params['power'] = province['owner']
      turn.provinces.build(params)
    end

    Initial.powers.each do |power, data|
      next unless data['units']
      data['units'].each do |unit|
        params = {}
        params['power'] = power
        params['province'] = unit['prov']
        params['type'] = unit['type']
        params['phase'] = table.phase
        turn.units.build(params)
      end
    end
    table
  end
end
