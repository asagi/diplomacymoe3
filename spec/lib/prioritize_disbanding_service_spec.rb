require "rails_helper"

RSpec.describe PrioritizeDisbandingService, type: :service do
  before :context do
    @master = create(:master)
  end

  describe "#call" do
    let(:result) { PrioritizeDisbandingService.call(table: @table, power: @power) }

    context "初期配置のオーストリア軍について判定" do
      before :context do
        user = create(:user)
        regulation = Regulation.create
        regulation.due_date = "2019-05-12"
        regulation.start_time = "07:00"
        @table = CreateInitializedTableService.call(user: user, regulation: regulation)
        @table = @table.start
        @power = @table.powers.find_by(symbol: "a")
      end

      example "海軍優先かつ地名のアルファベット順であること" do
        expect(result[0]).to eq "tri"
        expect(result[1]).to eq "bud"
        expect(result[2]).to eq "vie"
      end
    end

    context "初期配置の全軍をイギリス軍にして判定" do
      before :context do
        user = create(:user)
        regulation = Regulation.create
        regulation.due_date = "2019-05-12"
        regulation.start_time = "07:00"
        @table = CreateInitializedTableService.call(user: user, regulation: regulation)
        @table = @table.start
        @power = @table.powers.find_by(symbol: "e")
        @table.last_phase_units.map { |u| u.power = @power; u.save! }
      end

      example "第一候補は ank" do
        expect(result[0]).to eq "ank"
      end

      example "第二候補は bud" do
        expect(result[1]).to eq "bud"
      end

      example "第三候補は con" do
        expect(result[2]).to eq "con"
      end
    end
  end
end
