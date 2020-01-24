# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResoluteOrdersService, type: :service do
  describe '#call' do
    context 'Diagram 4:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
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
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g
        ).detect { |o| o.dest == 'sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r
        ).detect { |o| o.dest == 'sil' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決前の ber 陸軍への sil への移動命令のステータスは UNSLOVED' do
        expect(
          @turn.orders.find_by(unit: @unit_g).status_text
        ).to eq Order.status_text(code: Order::UNSLOVED)
      end

      example '解決前の war 陸軍への sil への移動命令のステータスは UNSLOVED' do
        expect(
          @turn.orders.find_by(unit: @unit_r).status_text
        ).to eq Order.status_text(code: Order::UNSLOVED)
      end

      example '解決後の ber 陸軍への sil への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の war 陸軍への sil への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example 'スタンドオフ発生地域として sil が返却される' do
        expect(result[1].include?('sil')).to be true
      end
    end

    context 'Diagram 5:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_kie = @turn.units.create(
          type: Fleet.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'kie'
        )
        @unit_g_ber = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_r_war = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_kie
        ).detect { |o| o.dest == 'ber' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ber
        ).detect { |o| o.dest == 'pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_war
        ).detect(&:hold?)
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の kie 海軍への ber への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_kie }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の ber 陸軍への pur への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ber }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の pur 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_war }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 6:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_a = @table.powers.create(symbol: Power::A)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_a = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f
        ).detect { |o| o.dest == 'pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a
        ).detect { |o| o.dest == 'ber' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ber 海軍への pru への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の pru 陸軍への ber への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end
    end

    context 'Diagram 7:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn)
        @unit_e_hol = @turn.units.create(
          type: Army.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'hol'
        )
        @unit_e_bel = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'bel'
        )
        @unit_f_nth = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'nth'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_hol
        ).detect { |o| o.dest == 'bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_bel
        ).detect { |o| o.dest == 'nth' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_nth
        ).detect { |o| o.dest == 'hol' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の hol 陸軍への bel への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_hol }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の bel 海軍への nth への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_bel }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の nth 海軍への hol への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_nth }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 8:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
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
          turn: @turn, power: @power_f, unit: @unit_f_mar
        ).detect { |o| o.dest == 'bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_gas
        ).detect { |o| o.target == 'f-a-mar-bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_bur
        ).detect(&:hold?)
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の mar 陸軍への bur への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_mar }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の gas 陸軍への A mar-bur への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_gas }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の bur 陸軍への維持命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_bur }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した bur 陸軍には撤退不可地域として mar が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_bur }.keepout
        ).to eq 'mar'
      end
    end

    context 'Diagram 9:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_g_bal = @turn.units.create(
          type: Fleet.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'bal'
        )
        @unit_r_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_sil
        ).detect { |o| o.dest == 'pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_bal
        ).detect { |o| o.target == 'g-a-sil-pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_pru
        ).detect(&:hold?)
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の sil 陸軍への pru への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の bal 海軍への A sil-pru への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_bal }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の pru 陸軍への維持命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_pru }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した pru 陸軍には撤退不可地域として pru が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_pru }.keepout
        ).to eq 'sil'
      end
    end

    context 'Diagram 10:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_lyo = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'lyo'
        )
        @unit_f_wes = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'wes'
        )
        @unit_i_nap = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'nap'
        )
        @unit_i_rom = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'rom'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_lyo
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_wes
        ).detect { |o| o.target == 'f-f-lyo-tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_nap
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_rom
        ).detect { |o| o.target == 'i-f-nap-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の wes 海軍への tys への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_lyo }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の wes 海軍への F lyo-tys への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_wes }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の nap 海軍への tys への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_nap }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の rom 海軍への F nap-tys への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_rom }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example 'スタンドオフ発生地域として tys が返却される' do
        expect(result[1].include?('tys')).to be true
      end
    end

    context 'Diagram 11:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_lyo = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'lyo'
        )
        @unit_f_wes = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'wes'
        )
        @unit_i_tys = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'tys'
        )
        @unit_i_rom = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'rom'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_lyo
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_wes
        ).detect { |o| o.target == 'f-f-lyo-tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_tys
        ).detect(&:hold?)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_rom
        ).detect { |o| o.target == 'i-f-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の wes 海軍への tys への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_lyo }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の wes 海軍への F lyo-tys への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_wes }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の tys 海軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_tys }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の rom 海軍への F tys H への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_rom }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 12:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_a = @table.powers.create(symbol: Power::A)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_a_boh = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'boh'
        )
        @unit_a_tyr = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'tyr'
        )
        @unit_g_mun = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'mun'
        )
        @unit_g_ber = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_r_war = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'war'
        )
        @unit_r_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'pru'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_boh
        ).detect { |o| o.dest == 'mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_tyr
        ).detect { |o| o.target == 'a-a-boh-mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_mun
        ).detect { |o| o.dest == 'sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ber
        ).detect { |o| o.target == 'g-a-mun-sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_war
        ).detect { |o| o.dest == 'sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_pru
        ).detect { |o| o.target == 'r-a-war-sil' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の boh 陸軍への mun への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_boh }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の tyr 陸軍への A boh-mun への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_tyr }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の mun 陸軍への sil への移動命令のステータスは DISLODGE' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_mun }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した mun 陸軍には撤退不可地域として boh が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_mun }.keepout
        ).to eq 'boh'
      end

      example '解決後の ber 陸軍への A mun-sil への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ber }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の war 陸軍への sil への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_war }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の pru 陸軍への A war-sil への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_pru }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example 'スタンドオフ発生地域として sil が返却される' do
        expect(result[1].include?('sil')).to be true
      end
    end

    context 'Diagram 13:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_t = @table.powers.create(symbol: Power::T)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_t_bul = @turn.units.create(
          type: Army.to_s,
          power: @power_t,
          phase: @table.phase,
          province: 'bul'
        )
        @unit_r_rum = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'rum'
        )
        @unit_r_ser = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'ser'
        )
        @unit_r_sev = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'sev'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_t, unit: @unit_t_bul
        ).detect { |o| o.dest == 'rum' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_rum
        ).detect { |o| o.dest == 'bul' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_ser
        ).detect { |o| o.target == 'r-a-rum-bul' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_sev
        ).detect { |o| o.dest == 'rum' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の bul 陸軍への rum への移動命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_t_bul }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '解決後の rum 陸軍への bul への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_rum }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の ser 陸軍への A bul-rum への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_ser }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の sev 陸軍への rum への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_sev }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 14:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_t = @table.powers.create(symbol: Power::T)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_t_bul = @turn.units.create(
          type: Army.to_s,
          power: @power_t,
          phase: @table.phase,
          province: 'bul'
        )
        @unit_t_bla = @turn.units.create(
          type: Fleet.to_s,
          power: @power_t,
          phase: @table.phase,
          province: 'bla'
        )
        @unit_r_rum = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'rum'
        )
        @unit_r_gre = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'gre'
        )
        @unit_r_ser = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'ser'
        )
        @unit_r_sev = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'sev'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_t, unit: @unit_t_bul
        ).detect { |o| o.dest == 'rum' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_t, unit: @unit_t_bla
        ).detect { |o| o.target == 't-a-bul-rum' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_rum
        ).detect { |o| o.dest == 'bul' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_gre
        ).detect { |o| o.target == 'r-a-rum-bul' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_ser
        ).detect { |o| o.target == 'r-a-rum-bul' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_sev
        ).detect { |o| o.dest == 'rum' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の bul 陸軍への rum への移動命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_t_bul }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '解決後の bla 海軍への A bul-rum への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_t_bla }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の rum 陸軍への bul への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_rum }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の gre 陸軍への A rum-bul への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_gre }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の ser 陸軍への A bul-rum への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_ser }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の sev 陸軍への rum への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_sev }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 15:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'pru'
        )
        @unit_g_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_r_war = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'war'
        )
        @unit_r_boh = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'boh'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_pru
        ).detect { |o| o.dest == 'war' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_sil
        ).detect { |o| o.target == 'g-a-pru-war' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_war
        ).detect(&:hold?)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_boh
        ).detect { |o| o.dest == 'sil' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の pru 陸軍への war への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_pru }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の sil 陸軍への A pru-war への支援命令のステータスは CUT' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.status_text
        ).to eq Order.status_text(code: Order::CUT)
      end

      example '解決後の war 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_war }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の boh 陸軍への sil への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_boh }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end
    end

    context 'Diagram 16:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'pru'
        )
        @unit_g_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_r_war = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'war'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_pru
        ).detect { |o| o.dest == 'war' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_sil
        ).detect { |o| o.target == 'g-a-pru-war' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_war
        ).detect { |o| o.dest == 'sil' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の pru 陸軍への war への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_pru }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の sil 陸軍への A pru-war への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の war 陸軍への sil への移動命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_war }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end
    end

    context 'Diagram 17:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_ber = @turn.units.create(
          type: Fleet.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_g_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_r_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'pru'
        )
        @unit_r_war = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'war'
        )
        @unit_r_bal = @turn.units.create(
          type: Fleet.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'bal'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ber
        ).detect { |o| o.dest == 'pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_sil
        ).detect { |o| o.target == 'g-f-ber-pru' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_pru
        ).detect { |o| o.dest == 'sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_war
        ).detect { |o| o.target == 'r-a-pru-sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_bal
        ).detect { |o| o.dest == 'pru' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ber 海軍への pru への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ber }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の sil 陸軍への A ber-pru への支援命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した sil 陸軍には撤退不可地域として pru が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.keepout
        ).to eq 'pru'
      end

      example '解決後の pru 陸軍への sil への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_pru }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の war 陸軍への A ber-pru への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_war }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の bal 海軍への pru への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_bal }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example 'スタンドオフ発生地域として pru が返却される' do
        expect(result[1].include?('pru')).to be true
      end
    end

    context 'Diagram 18:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_ber = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_g_mun = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'mun'
        )
        @unit_r_pru = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'pru'
        )
        @unit_r_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_r_boh = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'boh'
        )
        @unit_r_tyr = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'tyr'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ber
        ).detect(&:hold?)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_mun
        ).detect { |o| o.dest == 'sil' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_pru
        ).detect { |o| o.dest == 'ber' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_sil
        ).detect { |o| o.target == 'r-a-pru-ber' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_boh
        ).detect { |o| o.dest == 'mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_tyr
        ).detect { |o| o.target == 'r-a-boh-mun' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ber 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ber }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の mun 陸軍への sil への移動命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_mun }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '解決後の pru 陸軍への ber への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_pru }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の sil 陸軍への A pru-ber への支援命令のステータスは CUT' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_sil }.status_text
        ).to eq Order.status_text(code: Order::CUT)
      end

      example '解決後の boh 陸軍への mun への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_boh }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の tyr 陸軍への A boh-mun への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_tyr }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 19:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
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
          turn: @turn, power: @power_e, unit: @unit_e_lon
        ).detect { |o| o.dest == 'nwy' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_nth
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-nwy' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の lon 陸軍への nwy への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_lon }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の nth 海軍への A lon-nwy の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_nth }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      context '解決時に海路が存在しなかった場合' do
        before :example do
          @table = Table.create(turn: 0, phase: 'fal_3rd')
          override_proceed(table: @table)
          @power_e = @table.powers.create(symbol: Power::E)
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
            turn: @turn, power: @power_e, unit: @unit_e_lon
          ).detect { |o| o.dest == 'nwy' }
          @turn.orders << ListPossibleOrdersService.call(
            turn: @turn, power: @power_e, unit: @unit_e_nth
          ).detect(&:hold?)
        end

        let(:result) do
          ResoluteOrdersService.call(
            orders: @turn.orders.where(phase: @table.phase)
          )
        end

        example '解決後の lon 陸軍への nwy への移動命令のステータスは REFECTED' do
          expect(
            result[0].detect { |o| o.unit == @unit_e_lon }.status_text
          ).to eq Order.status_text(code: Order::REJECTED)
        end
      end
    end

    context 'Diagram 20:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn)
        @unit_e_lon = @turn.units.create(
          type: Army.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'lon'
        )
        @unit_e_eng = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'eng'
        )
        @unit_e_mao = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'mao'
        )
        @unit_f_wes = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'wes'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_lon
        ).detect { |o| o.dest == 'tun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_eng
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-tun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_mao
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-tun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_wes
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-tun' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の lon 陸軍への tun への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_lon }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の eng 海軍への A lon-tun の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_eng }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の mao 海軍への A lon-tun の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_mao }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の wes 海軍への A lon-tun の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_wes }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 21:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
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
          turn: @turn, power: @power_f, unit: @unit_f_spa
        ).detect { |o| o.dest == 'nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_lyo
        ).detect { |o| o.convoy? && o.target == 'f-a-spa-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_tys
        ).detect { |o| o.convoy? && o.target == 'f-a-spa-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_ion
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_tun
        ).detect { |o| o.support? && o.target == 'i-f-ion-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の spa 陸軍への nap への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_spa }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の lyo 海軍への A spa-nap の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_lyo }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の tys 海軍への A spa-nap の輸送命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tys }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '解決後の ion 海軍への tys への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_ion }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の tun 海軍への F ion-tys への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_tun }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 22:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_par = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'par'
        )
        @unit_f_mar = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'mar'
        )
        @unit_f_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'bur'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_par
        ).detect { |o| o.dest == 'bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_mar
        ).detect { |o| o.support? && o.target == 'f-a-par-bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_bur
        ).detect(&:hold?)
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の par 陸軍への bur への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_par }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の mar 陸軍への A par-bur への支援命令のステータスは REJECTED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_mar }.status_text
        ).to eq Order.status_text(code: Order::REJECTED)
      end

      example '解決後の bur 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_bur }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 23:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_par = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'par'
        )
        @unit_f_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'bur'
        )
        @unit_g_ruh = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ruh'
        )
        @unit_i_mar = @turn.units.create(
          type: Army.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'mar'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_par
        ).detect { |o| o.dest == 'bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_bur
        ).detect { |o| o.dest == 'mar' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ruh
        ).detect { |o| o.support? && o.target == 'f-a-par-bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_i, unit: @unit_i_mar
        ).detect { |o| o.dest == 'bur' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の par 陸軍への bur への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_par }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の bur 陸軍への mar への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_bur }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の mar 陸軍への A par-bur への支援命令のステータスは REJECTED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ruh }.status_text
        ).to eq Order.status_text(code: Order::REJECTED)
      end

      example '解決後の mar 陸軍への bur への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_mar }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end
    end

    context 'Diagram 24:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_g = @table.powers.create(symbol: Power::G)
        @power_f = @table.powers.create(symbol: Power::F)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_ruh = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ruh'
        )
        @unit_g_mun = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'mun'
        )
        @unit_f_par = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'par'
        )
        @unit_f_bur = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'bur'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ruh
        ).detect { |o| o.dest == 'bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_mun
        ).detect(&:hold?)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_par
        ).detect { |o| o.support? && o.target == 'g-a-ruh-bur' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_bur
        ).detect(&:hold?)
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ruh 陸軍への bur への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ruh }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の mun 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_mun }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の par 陸軍への A ruh-bur への支援命令のステータスは REJECTED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_par }.status_text
        ).to eq Order.status_text(code: Order::REJECTED)
      end

      example '解決後の bur 陸軍への維持命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_bur }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      context 'If Germany had supported its own attack (from Munich), ...' do
        before :example do
          @table = Table.create(turn: 0, phase: 'fal_3rd')
          override_proceed(table: @table)
          @power_g = @table.powers.create(symbol: Power::G)
          @power_f = @table.powers.create(symbol: Power::F)
          @turn = @table.turns.create(number: @table.turn)
          @unit_g_ruh = @turn.units.create(
            type: Army.to_s,
            power: @power_g,
            phase: @table.phase,
            province: 'ruh'
          )
          @unit_g_mun = @turn.units.create(
            type: Army.to_s,
            power: @power_g,
            phase: @table.phase,
            province: 'mun'
          )
          @unit_f_par = @turn.units.create(
            type: Army.to_s,
            power: @power_f,
            phase: @table.phase,
            province: 'par'
          )
          @unit_f_bur = @turn.units.create(
            type: Army.to_s,
            power: @power_f,
            phase: @table.phase,
            province: 'bur'
          )
          @table = @table.proceed
          @turn = @table.turns.find_by(number: @table.turn)
          @turn.orders << ListPossibleOrdersService.call(
            turn: @turn, power: @power_g, unit: @unit_g_ruh
          ).detect { |o| o.dest == 'bur' }
          @turn.orders << ListPossibleOrdersService.call(
            turn: @turn, power: @power_g, unit: @unit_g_mun
          ).detect { |o| o.support? && o.target == 'g-a-ruh-bur' }
          @turn.orders << ListPossibleOrdersService.call(
            turn: @turn, power: @power_f, unit: @unit_f_par
          ).detect(&:hold?)
          @turn.orders << ListPossibleOrdersService.call(
            turn: @turn, power: @power_f, unit: @unit_f_bur
          ).detect(&:hold?)
        end

        let(:result) do
          ResoluteOrdersService.call(
            orders: @turn.orders.where(phase: @table.phase)
          )
        end

        example '解決後の ruh 陸軍への bur への移動命令のステータスは SUCCEEDED' do
          expect(
            result[0].detect { |o| o.unit == @unit_g_ruh }.status_text
          ).to eq Order.status_text(code: Order::SUCCEEDED)
        end

        example '解決後の par 陸軍への A ruh-bur への支援命令のステータスは APPLIED' do
          expect(
            result[0].detect { |o| o.unit == @unit_g_mun }.status_text
          ).to eq Order.status_text(code: Order::APPLIED)
        end

        example '解決後の par 陸軍への維持命令のステータスは SUCCEEDED' do
          expect(
            result[0].detect { |o| o.unit == @unit_f_par }.status_text
          ).to eq Order.status_text(code: Order::SUCCEEDED)
        end

        example '解決後の bur 陸軍への維持命令のステータスは DISLODGED' do
          expect(
            result[0].detect { |o| o.unit == @unit_f_bur }.status_text
          ).to eq Order.status_text(code: Order::DISLODGED)
        end
      end
    end

    context 'Diagram 25:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_a = @table.powers.create(symbol: Power::A)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit_g_ruh = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'ruh'
        )
        @unit_g_mun = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'mun'
        )
        @unit_g_sil = @turn.units.create(
          type: Army.to_s,
          power: @power_g,
          phase: @table.phase,
          province: 'sil'
        )
        @unit_a_tyr = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'tyr'
        )
        @unit_a_boh = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'boh'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn = @table.turns.create(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_ruh
        ).detect { |o| o.dest == 'mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_mun
        ).detect { |o| o.dest == 'tyr' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_g, unit: @unit_g_sil
        ).detect { |o| o.dest == 'mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_tyr
        ).detect { |o| o.dest == 'mun' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_boh
        ).detect { |o| o.support? && o.target == 'g-a-sil-mun' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ruh 陸軍への mun への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_ruh }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の mun 陸軍への tyr への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_mun }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の sil 陸軍への mun への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_g_sil }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の tyr 陸軍への mun への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_tyr }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の boh 陸軍への A sil-mun への支援命令のステータスは REJECTED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_boh }.status_text
        ).to eq Order.status_text(code: Order::REJECTED)
      end
    end

    context 'Diagram 26:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_e_den = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'den'
        )
        @unit_e_hel = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'hel'
        )
        @unit_e_nth = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'nth'
        )
        @unit_r_ber = @turn.units.create(
          type: Army.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'ber'
        )
        @unit_r_ska = @turn.units.create(
          type: Fleet.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'ska'
        )
        @unit_r_bal = @turn.units.create(
          type: Fleet.to_s,
          power: @power_r,
          phase: @table.phase,
          province: 'bal'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_den
        ).detect { |o| o.dest == 'kie' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_nth
        ).detect { |o| o.dest == 'den' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_hel
        ).detect { |o| o.support? && o.target == 'e-f-nth-den' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_ber
        ).detect { |o| o.dest == 'kie' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_ska
        ).detect { |o| o.dest == 'den' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_bal
        ).detect { |o| o.support? && o.target == 'r-f-ska-den' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の den 海軍への kie への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_den }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の nth 海軍への den への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_nth }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の hel 海軍への F nth-den への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_hel }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の bel 陸軍への kie への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_ber }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の ska 海軍への den への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_ska }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の bal 海軍への A ska-den への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_bal }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 27:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_a = @table.powers.create(symbol: Power::A)
        @power_r = @table.powers.create(symbol: Power::R)
        @turn = @table.turns.create(number: @table.turn)
        @unit_a_ser = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'ser'
        )
        @unit_a_vie = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'vie'
        )
        @unit_r_gal = @turn.units.create(
          type: Army.to_s,
          power: @power_a,
          phase: @table.phase,
          province: 'gal'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_ser
        ).detect { |o| o.dest == 'bud' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_a, unit: @unit_a_vie
        ).detect { |o| o.dest == 'bud' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_r, unit: @unit_r_gal
        ).detect { |o| o.support? && o.target == 'a-a-ser-bud' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の ser 陸軍への bud への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_ser }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の vie 陸軍への den への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_a_vie }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の bal 陸軍への A ser-bud への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_r_gal }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 28:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_f = @table.powers.create(symbol: Power::F)
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
        @unit_f_bel = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'bel'
        )
        @unit_f_eng = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'eng'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_lon
        ).detect { |o| o.dest == 'bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_nth
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_bel
        ).detect { |o| o.dest == 'lon' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_eng
        ).detect { |o| o.convoy? && o.target == 'f-a-bel-lon' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の lon 陸軍への bel への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_lon }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の nth 海軍への A lon-bel の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_nth }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の bel 陸軍への lon への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_bel }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の eng 海軍への A bel-lon の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_eng }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 29:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_e = @table.powers.create(symbol: Power::E)
        @power_f = @table.powers.create(symbol: Power::F)
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
        @unit_e_eng = @turn.units.create(
          type: Fleet.to_s,
          power: @power_e,
          phase: @table.phase,
          province: 'eng'
        )
        @unit_f_bre = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'bre'
        )
        @unit_f_iri = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'iri'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_lon
        ).detect { |o| o.dest == 'bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_nth
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_e, unit: @unit_e_eng
        ).detect { |o| o.convoy? && o.target == 'e-a-lon-bel' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_bre
        ).detect { |o| o.dest == 'eng' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn, power: @power_f, unit: @unit_f_iri
        ).detect { |o| o.support? && o.target == 'f-f-bre-eng' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の lon 陸軍への bel への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_lon }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の nth 海軍への A lon-bel の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_nth }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の eng 海軍への A lon-bel の輸送命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_eng }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した eng 海軍には撤退不可地域として bre が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_e_eng }.keepout
        ).to eq 'bre'
      end

      example '解決後の bre 海軍への eng への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_bre }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の iri 海軍への F bre-eng への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_iri }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end
    end

    context 'Diagram 30:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_tun = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tun'
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
        @unit_i_nap = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'nap'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tun
        ).detect { |o| o.dest == 'nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tys
        ).detect { |o| o.convoy? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_ion
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_nap
        ).detect { |o| o.support? && o.target == 'i-f-ion-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の tys 海軍への A tun-nap の輸送命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tys }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '解決後の tun 陸軍への nap への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tun }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の nap 海軍への F ion-tys への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_nap }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の ion 海軍への tys への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_ion }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context 'Diagram 31:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_tun = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tun'
        )
        @unit_f_tys = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tys'
        )
        @unit_f_ion = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'ion'
        )
        @unit_i_rom = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'rom'
        )
        @unit_i_nap = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'nap'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tun
        ).detect { |o| o.dest == 'nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tys
        ).detect { |o| o.convoy? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_ion
        ).detect { |o| o.convoy? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_rom
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_nap
        ).detect { |o| o.support? && o.target == 'i-f-rom-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の tun 陸軍への nap への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tun }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の tys 海軍への A tun-nap の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tys }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の ion 海軍への A tun-nap の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_ion }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の rom 海軍への tys への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_rom }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の nap 海軍への F rom-tys への支援命令のステータスは CUT' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_nap }.status_text
        ).to eq Order.status_text(code: Order::CUT)
      end
    end

    context 'Diagram 32:' do
      before :example do
        @table = Table.create(turn: 0, phase: 'fal_3rd')
        override_proceed(table: @table)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_i = @table.powers.create(symbol: Power::I)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f_tun = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tun'
        )
        @unit_f_tys = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'tys'
        )
        @unit_f_ion = @turn.units.create(
          type: Fleet.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'ion'
        )
        @unit_f_apu = @turn.units.create(
          type: Army.to_s,
          power: @power_f,
          phase: @table.phase,
          province: 'apu'
        )
        @unit_i_rom = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'rom'
        )
        @unit_i_nap = @turn.units.create(
          type: Fleet.to_s,
          power: @power_i,
          phase: @table.phase,
          province: 'nap'
        )
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tun
        ).detect { |o| o.dest == 'nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_tys
        ).detect { |o| o.convoy? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_ion
        ).detect { |o| o.convoy? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_f,
          unit: @unit_f_apu
        ).detect { |o| o.support? && o.target == 'f-a-tun-nap' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_rom
        ).detect { |o| o.dest == 'tys' }
        @turn.orders << ListPossibleOrdersService.call(
          turn: @turn,
          power: @power_i,
          unit: @unit_i_nap
        ).detect { |o| o.support? && o.target == 'i-f-rom-tys' }
      end

      let(:result) do
        ResoluteOrdersService.call(
          orders: @turn.orders.where(phase: @table.phase)
        )
      end

      example '解決後の tun 陸軍への nap への移動命令のステータスは SUCCEEDED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tun }.status_text
        ).to eq Order.status_text(code: Order::SUCCEEDED)
      end

      example '解決後の tys 海軍への A tun-nap の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_tys }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の ion 海軍への A tun-nap の輸送命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_ion }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の apu 陸軍への A tun-nap への支援命令のステータスは APPLIED' do
        expect(
          result[0].detect { |o| o.unit == @unit_f_apu }.status_text
        ).to eq Order.status_text(code: Order::APPLIED)
      end

      example '解決後の rom 海軍への tys への移動命令のステータスは FAILED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_rom }.status_text
        ).to eq Order.status_text(code: Order::FAILED)
      end

      example '解決後の nap 海軍への F rom-tys への支援命令のステータスは DISLODGED' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_nap }.status_text
        ).to eq Order.status_text(code: Order::DISLODGED)
      end

      example '敗退した nap 海軍には撤退不可地域として tun が設定されている' do
        expect(
          result[0].detect { |o| o.unit == @unit_i_nap }.keepout
        ).to eq 'tun'
      end
    end
  end
end
