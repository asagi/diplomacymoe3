# frozen_string_literal: true

class CreateInitializedTableService
  def self.call(owner:, regulation: nil)
    regulation ||= Regulation.create
    new(owner: owner, regulation: regulation).call
  end

  def initialize(owner:, regulation:)
    @owner = owner[:user]
    @owner_desired_power = owner['desired_power']
    @regulation = regulation
  end

  def call
    table = Table.create(
      turn: Const.turns.initial,
      phase: 'fal_3rd',
      regulation: @regulation
    )
    table = setup_powers(table)
    table = setup_initial_turn(table)
    table = setup_initial_players(table)
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
    table.save!
    table
  end

  def setup_initial_turn(table)
    # 開幕ターン
    turn = table.turns.build

    MapUtil.provinces.each do |code, province|
      next unless province['owner']

      params = {}
      params['code'] = code[0, 3]
      params['type'] = province['type']
      params['name'] = province['name']
      params['jname'] = province['jname']
      params['supplycenter'] = !!province['supplycenter']
      params['power'] = province['owner']
      turn.provinces.build(params)
    end

    Initial.powers.each do |power, data|
      next unless data['units']

      data['units'].each do |unit|
        params = {}
        params['power'] = table.powers.find_by(symbol: power)
        params['province'] = unit['province']
        params['type'] = unit['type']
        params['phase'] = table.phase
        turn.units.build(params)
      end
    end
    table.save!
    table
  end

  def setup_initial_players(table)
    table = table.add_master
    table = table.add_player(user: @owner, desired_power: @owner_desired_power)
    table.save!
    table
  end
end
