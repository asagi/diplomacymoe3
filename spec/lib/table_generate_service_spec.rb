require 'rails_helper'

RSpec.describe TableGenerateService, type: :service do
  describe '#call' do
    let(:table) { TableGenerateService.call }

    describe '国' do
      example "7 国 +1 (管理人) が生成されている" do
        expect(table.powers.size).to eq 7 + 1
      end
    end

    describe 'ターン' do
      let(:turn_0) { table.turns.last }
      example "開幕ターンのみが生成されている" do
        expect(table.turns.size).to eq 1
        expect(turn_0.number).to eq 0
      end

      describe '地域' do
        let(:provinces) { turn_0.provinces }
        example "開幕ターンに領土情報が生成されている" do
          expect(provinces).not_to be_nil
        end

        let(:r_supplycenters) { provinces.where(power: Power::R).where(supplycenter: true) }
        example "ロシアは 4 つの補給都市を持つ" do
          expect(r_supplycenters.size).to eq 4
        end
      end

      describe 'ユニット' do
        let(:i_units) { turn_0.units.where(phase: table.phase).where(power: Power::I) }
        example "イタリアは 2 つの陸軍と 1 つの海軍を持つ" do
          expect(i_units.where(type: Army.to_s).size).to eq 2
          expect(i_units.where(type: Fleet.to_s).size).to eq 1
        end
      end
    end
  end
end
