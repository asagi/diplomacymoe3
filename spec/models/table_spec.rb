require "rails_helper"

RSpec.describe Table, type: :model do
  describe "#create" do
    context "Regulation 省略" do
      before :example do
        @table = Table.create(turn: 1, phase: Const.phases.spr_1st)
      end

      example "初期値" do
        expect(@table.turn).to eq 1
        expect(@table.phase).to eq Const.phases.spr_1st
        expect(@table.powers.empty?).to eq true
        expect(@table.regulation).to be nil
      end
    end

    context "Regulation 指定" do
      before :example do
        @regulation = Regulation.create
        @table = Table.create(turn: 1, phase: Const.phases.spr_1st, regulation: @regulation)
      end

      example "初期値" do
        expect(@table.turn).to eq 1
        expect(@table.phase).to eq Const.phases.spr_1st
        expect(@table.powers.empty?).to be true
        expect(@table.regulation).to eq @regulation
      end
    end
  end

  describe "#full?" do
    let(:table) { CreateInitializedTableService.call(user: @user) }

    context "参加者が 7 人に達していない場合" do
      before :example do
        create(:master)
        @user = create(:user)
      end

      example "fase を返す" do
        expect(table.full?).to be false
      end
    end

    context "参加者が 7 人に達している場合" do
      before :example do
        create(:master)
        @user = create(:user)
        @table = CreateInitializedTableService.call(user: @user)
        (1..6).each { @table = @table.add_player(user: create(:user)) }
      end

      example "true を返す" do
        expect(@table.full?).to be true
      end
    end
  end

  describe "#proceed" do
    context "CreateInitializedTableService.call で生成" do
      before :example do
        create(:master)
        @user = create(:user)
        @table = CreateInitializedTableService.call(user: @user)
        override_proceed(table: @table)
      end

      example "フェイズを進行させる" do
        @table = @table.proceed
        expect(@table.turn).to eq 1
        expect(@table.phase).to eq Const.phases.spr_1st
      end
    end
  end

  describe "#order_targets" do
    context "CreateInitializedTableService.call で生成" do
      before :example do
        create(:master)
        @user = create(:user)
        @table = CreateInitializedTableService.call(user: @user)
        override_proceed(table: @table)
      end

      let(:targets) { @table.order_targets }

      context "開幕ターンの場合" do
        example "命令可能なユニットは存在しない" do
          expect(targets.empty?).to be true
        end
      end

      context "第一ターンの場合" do
        example "初期配置のユニットが対象となる" do
          @table = @table.proceed
          expect(targets.size).to eq 22
        end
      end
    end
  end
end
