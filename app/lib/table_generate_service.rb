class TableGenerateService
  def self.call
    self.new.call
  end


  def call
    table = Table.new(turn: Const.turns.initial, phase: Const.phases.final)
    table = setup_powers(table)
    table = setup_initial_turn(table)
    table.save!
    table
  end


  private
  def setup_powers(table)
    # 国
    Master.powers.each do |symbol, data|
      params = {}
      params['symbol'] = symbol
      params['name'] = data['name']
      params['genitive'] = data['genitive']
      table.powers.build(data)
    end
    table
  end


  def setup_initial_turn(table)
    # 開幕ターン
    turn = table.turns.build

    Master.provinces.each do |code, province|
      next unless province['owner']
      params = {}
      params['code'] = code
      params['type'] = province['type']
      params['name'] = province['name']
      params['supplycenter'] = !!province['supplycenter']
      params['power'] = province['owner']
      turn.provinces.build(params)
    end

    Master.units.each do |unit|
      params = unit
      params['phase'] = table.phase
      turn.units.build(params)
    end
    table
  end
end
