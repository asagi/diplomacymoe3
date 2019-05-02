require 'rails_helper'

RSpec.describe Table, type: :model do
  before :example do
    @table = CreateInitializedTableService.call
  end


  describe '#proceed' do
    example "フェイズを進行させる" do
      @table = @table.proceed
      expect(@table.turn).to eq 1
      expect(@table.phase).to eq Const.phases.spr_1st
    end
  end


  describe '#order_targets' do
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
