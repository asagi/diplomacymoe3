require 'rails_helper'

RSpec.describe ResoluteRetreatsService, type: :service do
  describe '#call' do
    context "解隊" do
      before :example do
        @table = Table.create(turn: 1, phase: Const.phases.spr_1st)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(type: Army.to_s, power: Power::G, phase: @table.phase, province: 'bur', keepout: 'mar')
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(turn: @turn, power: @power_g, unit: @unit).detect{|r| r.disband?}
      end

      let(:result) { ResoluteRetreatsService.call(orders: @turn.orders.where(phase: @table.phase)) }

      example "解決後の bur 陸軍への解隊命令のステータスは SUCCEEDED" do
        expect(result.detect{|o| o.unit == @unit}.status_text).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context "撤退成功" do
      before :example do
        @table = Table.create(turn: 1, phase: Const.phases.spr_1st)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit = @turn.units.create(type: Army.to_s, power: Power::G, phase: @table.phase, province: 'bur', keepout: 'mar')
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(turn: @turn, power: @power_g, unit: @unit).detect{|r| r.dest == 'par'}
      end

      let(:result) { ResoluteRetreatsService.call(orders: @turn.orders.where(phase: @table.phase)) }

      example "解決後の bur 陸軍への par への撤退命令のステータスは SUCCEEDED" do
        expect(result.detect{|o| o.unit == @unit}.status_text).to eq Order.status_text(code: Order::SUCCEEDED)
      end
    end

    context "撤退の競合" do
      before :example do
        @table = Table.create(turn: 1, phase: Const.phases.spr_1st)
        @power_f = @table.powers.create(symbol: Power::F)
        @power_g = @table.powers.create(symbol: Power::G)
        @turn = @table.turns.create(number: @table.turn)
        @unit_f = @turn.units.create(type: Army.to_s, power: Power::F, phase: @table.phase, province: 'gas', keepout: 'bre')
        @unit_g = @turn.units.create(type: Army.to_s, power: Power::G, phase: @table.phase, province: 'bur', keepout: 'mar')
        @table = @table.proceed
        @turn = @table.turns.find_by(number: @table.turn)
        @standoff = []
        @turn.orders << ListPossibleRetreatsService.call(turn: @turn, power: @power_f, unit: @unit_f).detect{|r| r.dest == 'par'}
        @turn.orders << ListPossibleRetreatsService.call(turn: @turn, power: @power_g, unit: @unit_g).detect{|r| r.dest == 'par'}
      end

      let(:result) { ResoluteRetreatsService.call(orders: @turn.orders.where(phase: @table.phase)) }

      example "解決後の gas 陸軍への par への撤退命令のステータスは FAILED" do
        expect(result.detect{|o| o.unit == @unit_f}.status_text).to eq Order.status_text(code: Order::FAILED)
      end

      example "解決後の bur 陸軍への par への撤退命令のステータスは FAILED" do
        expect(result.detect{|o| o.unit == @unit_g}.status_text).to eq Order.status_text(code: Order::FAILED)
      end
    end
  end
end
