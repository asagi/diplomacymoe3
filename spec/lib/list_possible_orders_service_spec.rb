# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListPossibleOrdersService, type: :service do
  describe '#call' do
    context 'Diagram 1:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power = @table.powers.create(symbol: Power::F)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(
          type: Army.to_s,
          power: @power,
          phase: @table.phase,
          province: 'par'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
      end

      let(:ordermenu) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power,
          unit: @unit
        )
      end

      example 'par の陸軍はその場を維持できる' do
        sample = HoldOrder.new(power: @power, unit: @unit).to_s
        expect(ordermenu.any? { |o| o.to_s == sample }).to be true
      end

      example 'par の陸軍は 4 つの地域に移動できる' do
        expect(ordermenu.select(&:move?).size).to eq 4
      end

      example 'par の陸軍は pic に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'pic' }).to be true
      end

      example 'par の陸軍は bur に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'bur' }).to be true
      end

      example 'par の陸軍は gas に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'gas' }).to be true
      end

      example 'par の陸軍は bre に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'bre' }).to be true
      end
    end

    context 'Diagram 2:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power = @table.powers.create(symbol: Power::E)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power,
          phase: @table.phase,
          province: 'eng'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
      end

      let(:ordermenu) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power,
          unit: @unit
        )
      end

      example 'eng の海軍はその場を維持できる' do
        sample = HoldOrder.new(power: @power, unit: @unit).to_s
        expect(ordermenu.any? { |o| o.to_s == sample }).to be true
      end

      example 'eng の海軍は 8 つの地域に移動できる' do
        expect(ordermenu.select(&:move?).size).to eq 8
      end

      example 'eng の海軍は iri に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'iri' }).to be true
      end

      example 'eng の海軍は wal に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'wal' }).to be true
      end

      example 'eng の海軍は lon に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'lon' }).to be true
      end

      example 'eng の海軍は bel に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'bel' }).to be true
      end

      example 'eng の海軍は pic に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'pic' }).to be true
      end

      example 'eng の海軍は bre に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'bre' }).to be true
      end

      example 'eng の海軍は nth に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'nth' }).to be true
      end

      example 'eng の海軍は mao に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'mao' }).to be true
      end
    end

    context 'Diagram 3:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power_i = @table.powers.create(symbol: Power::I)
        @power_e = @table.powers.create(symbol: Power::E)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'rom'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
      end

      let(:ordermenu) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_e,
          unit: @unit
        )
      end

      example 'rom の海軍はその場を維持できる' do
        sample = HoldOrder.new(power: @power_e, unit: @unit).to_s
        expect(ordermenu.any? { |o| o.to_s == sample }).to be true
      end

      example 'rom の海軍は 3 つの地域に移動できる' do
        expect(ordermenu.select(&:move?).size).to eq 3
      end

      example 'rom の海軍は tus に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'tus' }).to be true
      end

      example 'rom の海軍は nap に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'nap' }).to be true
      end

      example 'rom の海軍は tys に移動できる' do
        expect(ordermenu.any? { |o| o.dest == 'tys' }).to be true
      end

      example 'rom の海軍は ven に移動できない' do
        expect(ordermenu.any? { |o| o.dest == 'ven' }).to be false
      end

      example 'rom の海軍は apu に移動できない' do
        expect(ordermenu.any? { |o| o.dest == 'apu' }).to be false
      end
    end

    context 'Diagram 4:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_r = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'war'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
      end

      let(:ordermenu_g) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_g,
          unit: @unit_g
        )
      end
      let(:ordermenu_r) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_r,
          unit: @unit_r
        )
      end

      example 'ber の陸軍は sil に移動できる' do
        expect(ordermenu_g.any? { |o| o.dest == 'sil' }).to be true
      end

      example 'war の陸軍は sil に移動できる' do
        expect(ordermenu_r.any? { |o| o.dest == 'sil' }).to be true
      end
    end

    context 'Diagram 8:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_mar = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'mar'
        )
        @unit_f_gas = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'gas'
        )
        @unit_g_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'bur'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_mar
        ).detect { |o| o.dest == 'bur' }
      end

      let(:ordermenu_f) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_gas
        )
      end

      example 'gas 陸軍は A mar-bur を支援できる' do
        expect(ordermenu_f.any? { |o| o.target == 'f-a-mar-bur' }).to be true
      end
    end

    context 'Diagram 19:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power_e = @table.powers.create(symbol: Power::E)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit_e_lon = @turn.units.create(
          type: Army.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'lon'
        )
        @unit_e_nth = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'nth'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_e,
          unit: @unit_e_lon
        ).detect { |o| o.dest == 'nwy' }
      end

      let(:ordermenu) do
        ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_e,
          unit: @unit
        )
      end

      example 'lon 陸軍は nwy への移動（海路）を選択できる' do
        @unit = @unit_e_lon
        expect(ordermenu.any? { |o| o.dest == 'nwy' }).to be true
      end

      example 'lon 陸軍は edi への移動（海路）を選択できる' do
        @unit = @unit_e_lon
        expect(ordermenu.any? { |o| o.dest == 'edi' }).to be true
      end

      example 'lon 陸軍は den への移動（海路）を選択できる' do
        @unit = @unit_e_lon
        expect(ordermenu.any? { |o| o.dest == 'den' }).to be true
      end

      example 'lon 陸軍は hol への移動（海路）を選択できる' do
        @unit = @unit_e_lon
        expect(ordermenu.any? { |o| o.dest == 'hol' }).to be true
      end

      example 'lon 陸軍は bel への移動（海路）を選択できる' do
        @unit = @unit_e_lon
        expect(ordermenu.any? { |o| o.dest == 'bel' }).to be true
      end

      example 'nth 海軍は A lon-nwy を輸送できる' do
        @unit = @unit_e_nth
        expect(
          ordermenu.any? { |o| o.convoy? && o.target == 'e-a-lon-nwy' }
        ).to be true
      end
    end

    context 'Diagram 21:' do
      before :example do
        @table = Table.create(turn: 0, phase: Table::Phase::FAL_3RD)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_spa = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'spa'
        )
        @unit_f_lyo = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'lyo'
        )
        @unit_f_tys = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tys'
        )
        @unit_i_ion = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'ion'
        )
        @unit_i_tun = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'tun'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_spa
        ).detect { |o| o.dest == 'nap' }
      end

      let(:ordermenu) do
        ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit
        )
      end

      example 'spa 陸軍は nap への移動（海路）を選択できる' do
        @unit = @unit_f_spa
        expect(ordermenu.any? { |o| o.dest == 'nap' }).to be true
      end

      example 'lyo 海軍は A spa-nap を輸送できる' do
        @unit = @unit_f_lyo
        expect(
          ordermenu.any? { |o| o.convoy? && o.target == 'f-a-spa-nap' }
        ).to be true
      end

      context '不可能な命令が選択できないことの確認' do
        example 'spa 陸軍は lyo への移動を選択できない' do
          @unit = @unit_f_spa
          expect(ordermenu.any? { |o| o.dest == 'lyo' }).to be false
        end

        example 'lyo 海軍は spa への移動を選択できない' do
          @unit = @unit_f_lyo
          expect(ordermenu.any? { |o| o.dest == 'spa' }).to be false
        end
      end
    end
  end
end
