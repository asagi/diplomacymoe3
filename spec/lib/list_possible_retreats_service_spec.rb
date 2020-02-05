# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListPossibleRetreatsService, type: :service do
  describe '#call' do
    context 'after Diagram 8:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
        override_proceed(table: @table)
        @turn = @table.turns.create(number: @table.turn_number)
        @unit_f_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'bur'
        )
        @unit_f_gas = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'gas'
        )
        @unit_g_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'bur',
          keepout: 'mar'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_g,
          unit: @unit_g_bur,
          standoff: @standoff
        )
      end

      example 'bur の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'bur の陸軍は 5 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 5
      end

      example 'bur の陸軍は par に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'par' }).to be true
      end

      example 'bur の陸軍は pic に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'pic' }).to be true
      end

      example 'bur の陸軍は ruh に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'ruh' }).to be true
      end

      example 'bur の陸軍は bel に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'bel' }).to be true
      end

      example 'bur の陸軍は mun に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'mun' }).to be true
      end

      example 'bur の陸軍は gas に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'gas' }).to be false
      end

      example 'bur の陸軍は mar に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'mar' }).to be false
      end
    end

    context 'Diagram 12:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_a = @table.powers.create(symbol: Power::A)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          prov_code: 'mun'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          prov_code: 'tyr'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'ber'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'war'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'pru'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'mun',
          keepout: 'boh'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = ['sil']
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_g,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'mun の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'mun の陸軍は 3 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 3
      end

      example 'mun の陸軍は kie に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'kie' }).to be true
      end

      example 'mun の陸軍は bur に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'bur' }).to be true
      end

      example 'mun の陸軍は ruh に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'ruh' }).to be true
      end

      example 'mun の陸軍は sil に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'sil' }).to be false
      end

      example 'mun の陸軍は boh に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'boh' }).to be false
      end

      example 'mun の陸軍は tyr に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'tyr' }).to be false
      end

      example 'mun の陸軍は ber に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ber' }).to be false
      end
    end

    context 'Diagram 13:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_t = @table.powers.create(symbol: Power::T)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'rum'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'ser'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'bul'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_t,
          phase: @table.phase,
          prov_code: 'bul',
          keepout: 'rum'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = ['sil']
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_t,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'bul の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'bul の陸軍は 2 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 2
      end

      example 'bul の陸軍は con に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'con' }).to be true
      end

      example 'bul の陸軍は gre に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'gre' }).to be true
      end

      example 'bul の陸軍は rum に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'rum' }).to be false
      end

      example 'bul の陸軍は ser に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ser' }).to be false
      end
    end

    context 'Diagram 14:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_t = @table.powers.create(symbol: Power::T)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_t,
          phase: @table.phase,
          prov_code: 'bla'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'rum'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'gre'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'ser'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'bul'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_t,
          phase: @table.phase,
          prov_code: 'bul',
          keepout: 'rum'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_t,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'bul の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'bul の陸軍は 1 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 1
      end

      example 'bul の陸軍は con に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'con' }).to be true
      end

      example 'bul の陸軍は rum に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'rum' }).to be false
      end

      example 'bul の陸軍は ser に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ser' }).to be false
      end

      example 'bul の陸軍は gre に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'gre' }).to be false
      end
    end

    context 'Diagram 16:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'pru'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'sil'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'war',
          keepout: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_r,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'war の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'war の陸軍は 4 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 4
      end

      example 'war の陸軍は ukr に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'ukr' }).to be true
      end

      example 'war の陸軍は gal に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'gal' }).to be true
      end

      example 'war の陸軍は mos に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'mos' }).to be true
      end

      example 'war の陸軍は lvn に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'lvn' }).to be true
      end

      example 'war の陸軍は pru に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'pru' }).to be false
      end

      example 'war の陸軍は sil に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'sil' }).to be false
      end
    end

    context 'Diagram 17:' do
      before :example do
        @table = Table.create(turn_number: 1, phase: Table::Phase::SPR_1ST)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'ber'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'sil'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'war'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'bal'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'sil',
          keepout: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_g,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'sil の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'sil の陸軍は 3 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 3
      end

      example 'sil の陸軍は gal に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'gal' }).to be true
      end

      example 'sil の陸軍は mun に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'mun' }).to be true
      end

      example 'sil の陸軍は boh に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'boh' }).to be true
      end

      example 'sil の陸軍は pru に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'pru' }).to be false
      end

      example 'sil の陸軍は war に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'war' }).to be false
      end

      example 'sil の陸軍は ber に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ber' }).to be false
      end
    end

    context 'Diagram 18:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'ber'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'pru'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'sil'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'mun'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          prov_code: 'tyr'
        )
        @dislodged_unit = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          prov_code: 'mun',
          keepout: 'boh'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_g,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'mun の陸軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'mun の陸軍は 3 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 3
      end

      example 'mun の陸軍は kie に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'kie' }).to be true
      end

      example 'mun の陸軍は ruh に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'ruh' }).to be true
      end

      example 'mun の陸軍は bur に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'bur' }).to be true
      end

      example 'mun の陸軍は sil に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'sil' }).to be false
      end

      example 'mun の陸軍は boh に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'boh' }).to be false
      end

      example 'mun の陸軍は tyr に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'tyr' }).to be false
      end

      example 'mun の陸軍は ber に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ber' }).to be false
      end
    end

    context 'Diagram 21:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'spa'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'lyo'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'tys'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'tun'
        )
        @dislodged_unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'tys',
          keepout: 'ion'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_f,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'tys の海軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'tys の海軍は 4 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 4
      end

      example 'tys の海軍は tus に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'tus' }).to be true
      end

      example 'tys の海軍は rom に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'rom' }).to be true
      end

      example 'tys の海軍は wes に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'wes' }).to be true
      end

      example 'tys の海軍は nap に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'nap' }).to be true
      end

      example 'tys の海軍は ion に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ion' }).to be false
      end

      example 'tys の海軍は tun に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'tun' }).to be false
      end

      example 'tys の海軍は lyo に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'lyo' }).to be false
      end
    end

    context 'Diagram 29:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_e,
          phase: @table.phase,
          prov_code: 'bel'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          prov_code: 'nth'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'eng'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'iri'
        )
        @dislodged_unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          prov_code: 'eng',
          keepout: 'bre'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_e,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'eng の海軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'eng の海軍は 4 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 4
      end

      example 'eng の海軍は lon に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'lon' }).to be true
      end

      example 'eng の海軍は mao に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'mao' }).to be true
      end

      example 'eng の海軍は pic に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'pic' }).to be true
      end

      example 'eng の海軍は wal に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'wal' }).to be true
      end

      example 'eng の海軍は nth に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'nth' }).to be false
      end

      example 'eng の海軍は bel に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'bel' }).to be false
      end

      example 'eng の海軍は bre に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'bre' }).to be false
      end

      example 'eng の海軍は iri に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'iri' }).to be false
      end
    end

    context 'Diagram 30:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'tun'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'tys'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'nap'
        )
        @dislodged_unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'tys',
          keepout: 'ion'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_f,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'tys の海軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'tys の海軍は 4 つの地域に撤退できる' do
        expect(ordermenu.select(&:retreat?).size).to eq 4
      end

      example 'tys の海軍は tus に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'tus' }).to be true
      end

      example 'tys の海軍は rom に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'rom' }).to be true
      end

      example 'tys の海軍は wes に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'wes' }).to be true
      end

      example 'tys の海軍は lyo に撤退できる' do
        expect(ordermenu.any? { |o| o.dest == 'lyo' }).to be true
      end

      example 'tys の海軍は ion に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ion' }).to be false
      end

      example 'tys の海軍は tun に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'tun' }).to be false
      end

      example 'tys の海軍は nap に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'nap' }).to be false
      end
    end

    context 'Diagram 32:' do
      before :example do
        @table = Table.create(turn_number: 0, phase: Table::Phase::FAL_3RD)
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn_number)
        @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'nap'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'tys'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'ion'
        )
        @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          prov_code: 'apu'
        )
        @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'rom'
        )
        @dislodged_unit = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          prov_code: 'nap',
          keepout: 'tun'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn_number)
        @standoff = []
      end

      let(:ordermenu) do
        ListPossibleRetreatsService.call(
          power: @power_i,
          unit: @dislodged_unit,
          standoff: @standoff
        )
      end

      example 'nap の海軍はその場での解隊を選択できる' do
        expect(ordermenu.any?(&:disband?)).to be true
      end

      example 'nap の海軍は撤退できる地域がない' do
        expect(ordermenu.select(&:retreat?).size).to eq 0
      end

      example 'nap の海軍は ion に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'ion' }).to be false
      end

      example 'nap の海軍は apu に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'apu' }).to be false
      end

      example 'nap の海軍は rom に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'rom' }).to be false
      end

      example 'nap の海軍は tys に撤退できない' do
        expect(ordermenu.any? { |o| o.dest == 'tys' }).to be false
      end
    end
  end
end
