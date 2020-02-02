# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResoluteRetreatsService, type: :service do
  describe '#call' do
    context '解隊' do
      before :example do
        @table = Table.create(turn: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'bur',
          keepout: 'mar'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(
          turn: @turn,
          power: @power_g,
          unit: @unit
        ).detect(&:disband?)
      end

      let(:result) do
        ResoluteRetreatsService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の bur 陸軍への解隊命令のステータスは SUCCEEDED' do
        expect(
          result.detect { |o| o.unit == @unit }.status
        ).to eq Order::Status::SUCCEEDED
      end
    end

    context '撤退成功' do
      before :example do
        @table = Table.create(turn: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'bur',
          keepout: 'mar'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(
          turn: @turn,
          power: @power_g,
          unit: @unit
        ).detect { |r| r.dest == 'par' }
      end

      let(:result) do
        ResoluteRetreatsService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の bur 陸軍への par への撤退命令のステータスは SUCCEEDED' do
        expect(
          result.detect { |o| o.unit == @unit }.status
        ).to eq Order::Status::SUCCEEDED
      end
    end

    context '撤退の競合' do
      before :example do
        @table = Table.create(turn: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'gas',
          keepout: 'bre'
        )
        @unit_g = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'bur',
          keepout: 'mar'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f
        ).detect { |r| r.dest == 'par' }
        @turn.orders << ListPossibleRetreatsService.call(
          turn: @turn,
          power: @power_g,
          unit: @unit_g
        ).detect { |r| r.dest == 'par' }
      end

      let(:result) do
        ResoluteRetreatsService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の gas 陸軍への par への撤退命令のステータスは FAILED' do
        expect(
          result.detect { |o| o.unit == @unit_f }.status
        ).to eq Order::Status::FAILED
      end

      example '解決後の bur 陸軍への par への撤退命令のステータスは FAILED' do
        expect(
          result.detect { |o| o.unit == @unit_g }.status
        ).to eq Order::Status::FAILED
      end
    end
  end
end
