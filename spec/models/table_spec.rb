# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Table, type: :model do
  before :example do
    create(:master)
  end

  let(:user) { create(:user) }
  let(:table) { CreateInitializedTableService.call(owner: { user: user }) }

  describe '#create' do
    context 'Regulation 省略' do
      before :example do
        @table = Table.create(turn: 1, phase: 'spr_1st')
      end

      example '初期値' do
        expect(@table.turn).to eq 1
        expect(@table.phase_spr_1st?).to be true
        expect(@table.powers.empty?).to be true
        expect(@table.regulation).to be nil
      end
    end

    context 'Regulation 指定' do
      before :example do
        @regulation = Regulation.create
        @table = Table.create(
          turn: 1,
          phase: 'spr_1st',
          regulation: @regulation
        )
      end

      example '初期値' do
        expect(@table.turn).to eq 1
        expect(@table.phase_spr_1st?).to be true
        expect(@table.powers.empty?).to be true
        expect(@table.regulation).to eq @regulation
      end
    end
  end

  describe '#add_player' do
    context '8 人目の参加者が登録しようとした場合' do
      before :example do
        6.times { table.add_player(user: create(:user)) }
      end

      example '例外を返す' do
        expect do
          expect do
            table.add_player(user: create(:user))
          end.to raise_error(described_class::NoPlaceAvailableError)
        end.to_not change(table.players, :size).from(7 + 1)
      end
    end
  end

  describe '#full?' do
    context '参加者が 7 人に達していない場合' do
      example 'fase を返す' do
        expect(table.full?).to be false
      end
    end

    context '参加者が 7 人に達している場合' do
      before :example do
        6.times { @table = table.add_player(user: create(:user)) }
      end

      example 'true を返す' do
        expect(@table.full?).to be true
      end
    end
  end

  describe '#proceed' do
    context 'CreateInitializedTableService.call で生成' do
      before :example do
        override_proceed(table: table)
      end

      example 'フェイズを進行させる' do
        @table = table.proceed
        expect(@table.turn).to eq 1
        expect(@table.phase_spr_1st?).to be true
      end
    end
  end

  describe '#order_targets' do
    context 'CreateInitializedTableService.call で生成' do
      before :example do
        override_proceed(table: table)
      end

      let(:targets) { table.order_targets }

      context '開幕ターンの場合' do
        example '命令可能なユニットは存在しない' do
          expect(targets.empty?).to be true
        end
      end

      context '第一ターンの場合' do
        example '初期配置のユニットが対象となる' do
          @table = table.proceed
          expect(targets.size).to eq 22
        end
      end
    end
  end
end
