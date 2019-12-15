require "rails_helper"

RSpec.describe ArrangeUnitsService, type: :service do
  describe "#call" do
    context "外交フェイズ" do
      context "維持" do
        before :context do
          @table = Table.create(turn: 0, phase: Const.phases.fal_3rd)
          @power_g = @table.powers.create(symbol: Power::G)
          @turn = @table.turns.create(number: @table.turn)
          @unit = @turn.units.create(type: Army.to_s, power: @power_g, phase: @table.phase, province: "bur")
          @table = @table.proceed
          @turn = @table.current_turn
          @order = ListPossibleOrdersService.call(turn: @turn, power: @power_g, unit: @unit).detect { |o| o.hold? }
          @order.succeed
          @turn.orders << @order
        end

        let(:table) { ArrangeUnitsService.call(table: @table) }

        example "bur にドイツ陸軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "bur")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_g
          expect(unit.keepout).to be_nil
        end
      end

      context "移動" do
        before :context do
          @table = Table.create(turn: 0, phase: Const.phases.fal_3rd)
          @power_g = @table.powers.create(symbol: Power::G)
          @turn = @table.turns.create(number: @table.turn)
          @unit = @turn.units.create(type: Army.to_s, power: @power_g, phase: @table.phase, province: "bur")
          @table = @table.proceed
          @turn = @table.current_turn
          @order = ListPossibleOrdersService.call(turn: @turn, power: @power_g, unit: @unit).detect { |o| o.dest == "mar" }
          @order.succeed
          @turn.orders << @order
        end

        let(:table) { ArrangeUnitsService.call(table: @table) }

        example "bur にドイツ陸軍がないこと" do
          unit = table.current_turn.units.where(phase: table.phase).find_by(province: "bur")
          expect(unit).to be_nil
        end

        example "mar にドイツ陸軍があること" do
          unit = table.current_turn.units.where(phase: table.phase).find_by(province: "mar")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_g
          expect(unit.keepout).to be_nil
        end
      end

      context "支援" do
        before :context do
          @table = Table.create(turn: 0, phase: Const.phases.fal_3rd)
          @power_g = @table.powers.create(symbol: Power::G)
          @turn = @table.turns.create(number: @table.turn)
          @unit_g_bur = @turn.units.create(type: Army.to_s, power: @power_g, phase: @table.phase, province: "bur")
          @unit_g_gas = @turn.units.create(type: Army.to_s, power: @power_g, phase: @table.phase, province: "gas")
          @table = @table.proceed
          @turn = @table.current_turn
          params = { turn: @turn, power: @power_g, unit: @unit_g_bur }
          @order = ListPossibleOrdersService.call(params).detect { |o| o.hold? }
          @order.succeed
          @turn.orders << @order
          params = { turn: @turn, power: @power_g, unit: @unit_g_gas }
          @order = ListPossibleOrdersService.call(params).detect { |o| o.support? && o.target == "g-a-bur" }
          @order.succeed
          @turn.orders << @order
        end

        let(:table) { ArrangeUnitsService.call(table: @table) }

        example "bur にドイツ陸軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "bur")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_g
          expect(unit.keepout).to be_nil
        end

        example "gas にドイツ陸軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "gas")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_g
          expect(unit.keepout).to be_nil
        end
      end

      context "輸送" do
        before :context do
          @table = Table.create(turn: 0, phase: Const.phases.fal_3rd)
          @power_e = @table.powers.create(symbol: Power::E)
          @turn = @table.turns.create(number: @table.turn)
          @unit_e_lon = @turn.units.create(type: Army.to_s, power: @power_e, phase: @table.phase, province: "lon")
          @unit_e_nth = @turn.units.create(type: Fleet.to_s, power: @power_e, phase: @table.phase, province: "nth")
          @table = @table.proceed
          @turn = @table.current_turn
          params = { turn: @turn, power: @power_e, unit: @unit_e_lon }
          @order = ListPossibleOrdersService.call(params).detect { |o| o.dest == "bel" }
          @order.succeed
          @turn.orders << @order
          params = { turn: @turn, power: @power_e, unit: @unit_e_nth }
          @order = ListPossibleOrdersService.call(params).detect { |o| o.convoy? && o.target == "e-a-lon-bel" }
          @order.apply
          @turn.orders << @order
        end

        let(:table) { ArrangeUnitsService.call(table: @table) }

        example "lon にイギリス陸軍がないこと" do
          unit = table.current_turn.units.where(phase: table.phase).find_by(province: "lon")
          expect(unit).to be_nil
        end

        example "bel にイギリス陸軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "bel")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_e
          expect(unit.keepout).to be_nil
        end

        example "nth にイギリス海軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "nth")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_e
          expect(unit.keepout).to be_nil
        end
      end
    end

    context "撤退フェイズ" do
      context "撤退" do
        before :example do
          @table = Table.create(turn: 1, phase: Const.phases.spr_1st)
          @power_g = @table.powers.create(symbol: Power::G)
          @turn = @table.turns.create(number: @table.turn)
          @unit = @turn.units.create(type: Army.to_s, power: @power_g, phase: @table.phase, province: "bur", keepout: "mar")
          @table = @table.proceed
          @turn = @table.current_turn
          @order = ListPossibleRetreatsService.call(turn: @turn, power: @power_g, unit: @unit).detect { |r| r.dest == "par" }
          @order.succeed
          @turn.orders << @order
        end

        let(:table) { ArrangeUnitsService.call(table: @table) }

        example "par に撤退したドイツ陸軍があること" do
          unit = @turn.units.where(phase: table.phase).find_by(province: "par")
          expect(unit).not_to be_nil
          expect(unit.power).to eq @power_g
          expect(unit.keepout).to be_nil
        end
      end
    end
  end
end
