# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProceedPhaseService, type: :service do
  before :example do
    create(:master)
  end

  describe '#call' do
    let(:user) { create(:user) }
    let(:table) { ProceedPhaseService.call(table: @table) }

    context 'ロビーから廃卓へ（初回更新時に人数不足）' do
      before :example do
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
      end

      example '更新前の卓のステータスが CREATED であること' do
        travel_to('2019-05-12 06:50') do
          expect(
            table.status
          ).to eq Table::Status::CREATED
        end
      end

      example '更新後の卓のステータスが DISCARDED であること' do
        travel_to('2019-05-12 07:00') do
          expect(
            table.status
          ).to eq Table::Status::DISCARDED
        end
      end
    end

    context 'ロビーから開始へ（初回更新時に７人登録）' do
      before :example do
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        6.times { @table = @table.add_player(user: create(:user)) }
      end

      example '更新後の卓のステータスが STARTED であること' do
        travel_to('2019-05-12 07:00') do
          expect(
            table.status
          ).to eq Table::Status::STARTED
        end
      end

      example '更新後の卓のターンが 1 年目の春外交フェイズであること' do
        travel_to('2019-05-12 07:00') do
          expect(table.turn).to eq 1
          expect(table.phase_spr_1st?).to be true
        end
      end
    end

    context '春外交から秋外交へ' do
      before :example do
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        @table = @table.start
        @table.period = '2019-05-12 07:00'
        # 仮想命令登録
        power_a = @table.powers.find_by(symbol: 'a')
        unit_e_lon = @table.last_phase_units.find_by(province: 'lon')
        @table.current_turn.orders << MoveOrder.new(
          power: power_a,
          unit: unit_e_lon,
          dest: 'nth'
        )
        # 保存
        @table.save!
      end

      example '更新前には F lon-nth の仮想命令が登録されていること' do
        travel_to('2019-05-12 06:50') do
          orders = table.current_turn.orders.where(phase: Table::Phase::SPR_1ST)
          expect(orders.size).to eq 1
          expect(orders.where(type: MoveOrder.to_s).size).to eq 1
          order = orders[0]
          expect(order.power).not_to eq order.unit.power
        end
      end

      example '卓のターンが 1 年目の秋外交フェイズであること' do
        travel_to('2019-05-12 07:00') do
          expect(table.turn).to eq 1
          expect(table.phase_fal_1st?).to be true
        end
      end

      example '更新後には F lon-nth の仮想命令が削除されていること' do
        travel_to('2019-05-12 07:00') do
          orders = table.current_turn.orders.where(phase: Table::Phase::SPR_1ST)
          expect(orders.where(type: MoveOrder.to_s).size).to eq 0
        end
      end

      example '1 年目の春外交フェイズに 22 の維持命令が生成されていること' do
        travel_to('2019-05-12 07:00') do
          orders = table.current_turn.orders.where(phase: Table::Phase::SPR_1ST)
          expect(orders.size).to eq 22
          expect(orders.where(type: HoldOrder.to_s).size).to eq 22
        end
      end

      example '1 年目の春外交フェイズに 22 のユニットが生成されていること' do
        travel_to('2019-05-12 07:00') do
          turn = table.turns.find_by(number: 1)
          units = turn.units.where(phase: Table::Phase::SPR_1ST)
          expect(units.size).to eq 22
        end
      end

      example '1 年目の春撤退フェイズに 22 のユニットが生成されていること' do
        travel_to('2019-05-12 07:00') do
          turn = table.turns.find_by(number: 1)
          units = turn.units.where(phase: Table::Phase::SPR_2ND)
          expect(units.size).to eq 22
        end
      end
    end

    context '春外交から春撤退へ' do
      before :example do
        # 卓作成
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        # 1901 年春外交フェイズに進む
        @table = @table.start
        # F lon が敗退したことにする
        power_e = @table.powers.find_by(symbol: Power::E)
        turn = @table.current_turn
        unit_e = @table.last_phase_units.find_by(province: 'lon')
        order = ListPossibleOrdersService.call(
          turn: turn,
          power: power_e,
          unit: unit_e
        ).detect(&:hold?)
        order.keepout = 'eng'
        order.status = Order::DISLODGED
        turn.orders << order
        # 更新期限調整
        @table.period = '2019-05-12 07:00'
        @table.save!
      end

      example '卓のターンが 1 年目の春撤退フェイズであること' do
        travel_to('2019-05-12 07:00') do
          expect(table.turn).to eq 1
          expect(table.phase_spr_2nd?).to be true
        end
      end

      example '1 年目の春外交フェイズに 22 の維持命令が生成されていること' do
        travel_to('2019-05-12 07:00') do
          orders = table.current_turn.orders.where(phase: Table::Phase::SPR_1ST)
          expect(orders.size).to eq 22
          expect(orders.where(type: HoldOrder.to_s).size).to eq 22
        end
      end

      example '1 年目の春撤退フェイズに F lon の解散命令が生成されていること' do
        travel_to('2019-05-12 07:00') do
          turn = table.turns.find_by(number: 1)
          orders = turn.orders.where(phase: Table::Phase::SPR_2ND)
          expect(orders.size).to eq 1
          expect(orders[0].type).to eq DisbandOrder.to_s
        end
      end
    end

    context '秋撤退から制覇終了へ' do
      before :example do
        # 卓作成
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        # 1901 年春外交フェイズに進む
        @table = @table.start
        # 1901 年秋撤退フェイズに進む
        @table.phase_fal_2nd!
        # 初期ユニット情報を秋外交フェイズにコピー
        power_e = @table.powers.find_by(symbol: 'e')
        @table.turns.find_by(number: 0).units.each do |unit|
          new_unit = unit.dup
          new_unit.phase = @table.phase
          new_unit.power = power_e
          @table.current_turn.units << new_unit
        end
        # 更新期限調整
        @table.period = '2019-05-12 07:00'
        @table.save!
      end

      example '卓のステータスが制覇終了であること' do
        travel_to('2019-05-12 07:00') do
          expect(table.status).to eq Table::Status::SOLO
        end
      end

      example 'イギリスの領地が 22 であること' do
        travel_to('2019-05-12 07:00') do
          power_e = table.powers.find_by(symbol: 'e')
          expect(power_e.supply_centers.size).to eq 22
        end
      end
    end

    context '秋撤退から翌春外交へ' do
      before :example do
        # 卓作成
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        # 1901 年春外交フェイズに進む
        @table = @table.start
        # 1901 年秋撤退フェイズに進む
        @table.phase_fal_2nd!
        # 初期ユニット情報を秋外交フェイズにコピー
        @table.turns.find_by(number: 0).units.each do |unit|
          new_unit = unit.dup
          new_unit.phase = @table.phase
          @table.current_turn.units << new_unit
        end
        # tun にイギリス海軍設置
        power_e = @table.powers.find_by(symbol: 'e')
        @table.current_turn.units.create(
          type: Fleet.to_s,
          power: power_e,
          province: 'tun',
          phase: @table.phase
        )
        # 更新期限調整
        @table.period = '2019-05-12 07:00'
        @table.save!
      end

      example '卓のターンが 2 年目の春外交フェイズであること' do
        travel_to('2019-05-12 07:00') do
          expect(table.turn).to eq 2
          expect(table.phase_spr_1st?).to be true
        end
      end

      example 'イギリスの領地が 4 であること' do
        travel_to('2019-05-12 07:00') do
          power_e = table.powers.find_by(symbol: 'e')
          expect(power_e.supply_centers.size).to eq 4
        end
      end
    end

    context '秋撤退から秋調整へ：増設可能' do
      before :example do
        # 卓作成
        regulation = Regulation.create
        regulation.due_date = '2019-05-12'
        regulation.start_time = '07:00'
        @table = CreateInitializedTableService.call(
          owner: { user: user },
          regulation: regulation
        )
        # 1901 年春外交フェイズに進む
        @table = @table.start
        # 1901 年秋撤退フェイズに進む
        @table.phase_fal_2nd!
        # 初期ユニット情報を秋外交フェイズにコピー
        @table.turns.find_by(number: 0).units.each do |unit|
          new_unit = unit.dup
          new_unit.phase = @table.phase
          @table.current_turn.units << new_unit
        end
        # tun にイギリス海軍設置
        power_e = @table.powers.find_by(symbol: 'e')
        @table.current_turn.units.create(
          type: Fleet.to_s,
          power: power_e,
          province: 'tun',
          phase: @table.phase
        )
        # lon からユニット除去
        @table.current_turn
              .units
              .where(phase: @table.phase)
              .find_by(province: 'lon')
              .delete

        # 更新期限調整
        @table.period = '2019-05-12 07:00'
        @table.save!
      end

      example '卓のターンが 2 年目の秋調整フェイズであること' do
        travel_to('2019-05-12 07:00') do
          expect(table.turn).to eq 1
          expect(table.phase_fal_3rd?).to be true
        end
      end

      example 'イギリスの領地が 4 であること' do
        travel_to('2019-05-12 07:00') do
          supplycenters = table
                          .current_turn
                          .provinces
                          .where(power: 'e')
                          .where(supplycenter: true)
          expect(supplycenters.size).to eq 4
        end
      end

      example 'イギリスのユニットが 3 であること' do
        travel_to('2019-05-12 07:00') do
          power_e = table.powers.find_by(symbol: 'e')
          expect(table.last_phase_units.where(power: power_e).size).to eq 3
        end
      end
    end
  end
end
