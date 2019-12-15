require "rails_helper"

RSpec.describe CreateInitializedTableService, type: :service do
  describe "#call" do
    let(:table) { CreateInitializedTableService.call(user: @user) }
    let(:units) { turn_0.units.where(phase: table.phase).where(power: @power) }

    before :example do
      @master = User.find_or_create_by(uid: ENV["MASTER_USER_01"], admin: true)
      @user = User.find_or_create_by(uid: "12345")
    end

    describe "国" do
      example "7 国 +1 (管理人) が生成されている" do
        expect(table.powers.size).to eq 7 + 1
      end
    end

    describe "プレイヤー" do
      example "生成された卓には最初のプレイヤーとして管理人と卓を立てたユーザーが登録されている" do
        expect(table.players.size).to eq 2
        master = table.players.find_by(user_id: @master.id)
        expect(master).not_to be_nil
        expect(master.power.symbol).to eq "x"
        expect(table.players.find_by(user_id: @user.id)).not_to be_nil
      end
    end

    describe "ターン" do
      let(:turn_0) { table.turns.last }

      example "開幕ターンのみが生成されている" do
        expect(table.turns.size).to eq 1
        expect(turn_0.number).to eq 0
      end

      describe "地域" do
        let(:provinces) { turn_0.provinces }
        example "開幕ターンに領土情報が生成されている" do
          expect(provinces).not_to be_nil
        end

        let(:r_supplycenters) { provinces.where(power: Power::R).where(supplycenter: true) }
        example "ロシアは 4 つの補給都市を持つ" do
          expect(r_supplycenters.size).to eq 4
        end
      end

      describe "ユニット" do
        example "イタリアは 2 つの陸軍と 1 つの海軍を持つ" do
          @power = table.powers.find_by(symbol: Power::I)
          expect(units.where(type: Army.to_s).size).to eq 2
          expect(units.where(type: Fleet.to_s).size).to eq 1
        end
      end
    end
  end
end
