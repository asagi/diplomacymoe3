# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe '#to_key' do
    context 'Diagram 5:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
      end

      example 'ドイツの ber 陸軍への sil への移動命令' do
        @unit_g = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'ber'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_g,
          unit: @unit_g
        ).detect { |o| o.dest == 'sil' }
        expected_key = 'g-a-ber-sil'
        expect(
          @turn.orders.find_by(unit: @unit_g).to_key
        ).to eq expected_key
      end

      example 'ロシアの war 陸軍への維持命令' do
        @unit_r = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'war'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_r,
          unit: @unit_r
        ).detect(&:hold?)
        expected_key = 'r-a-war'
        expect(
          @turn.orders.find_by(unit: @unit_r).to_key
        ).to eq expected_key
      end
    end

    context 'Diagram 8:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn_number)
        @unit_f_mar = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'mar'
        )
        @unit_f_gas = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'gas'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_mar
        ).detect { |o| o.dest == 'bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_gas
        ).detect { |o| o.target == 'f-a-mar-bur' }
      end

      example 'フランスの gas 陸軍への A mar-bur への支援命令' do
        expected_key = 'f-a-gas'
        expect(
          @turn.orders.find_by(unit: @unit_f_gas).to_key
        ).to eq expected_key
      end
    end

    context 'その他:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn_number)
        @unit_f_spa = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'spa_nc'
        )
        @unit_f_bul = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'bul_ec'
        )
        @unit_f_con = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'con'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_spa
        ).detect(&:hold?)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_bul
        ).detect { |o| o.dest == 'bla' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_con
        ).detect { |o| o.support? && o.target == 'f-f-bul_ec-bla' }
      end

      example 'spa(nc) 海軍の維持命令' do
        expect(
          @turn.orders.find_by(unit: @unit_f_spa).to_s
        ).to eq 'F spa(nc) H'
      end

      example 'bul(ec) 海軍の bla への移動命令' do
        expect(
          @turn.orders.find_by(unit: @unit_f_bul).to_s
        ).to eq 'F bul(ec)-bla'
      end

      example 'con 海軍の F bul(ec)-bla への支援命令' do
        expect(
          @turn.orders.find_by(unit: @unit_f_con).to_s
        ).to eq 'F con S F bul(ec)-bla'
      end
    end
  end
end
