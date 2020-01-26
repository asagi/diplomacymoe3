# frozen_string_literal: true

class ProceedPhaseService
  def self.call(table:)
    new(table: table).call
  end

  def initialize(table:)
    @table = table
  end

  def call
    return @table if @table.status_discarded?
    return @table if @table.status_closed?

    # ロック前状態取得
    turn = @table.turn
    phase = @table.phase

    # 卓をロック
    @table.with_lock do
      # ロック取得前にフェイズが変化していたら終了
      raise ActiveRecord::Rollback unless @table.turn == turn
      raise ActiveRecord::Rollback unless @table.phase == phase

      proceed_phase
      @table.save!
    end
    @table
  end

  private

  def proceed_phase
    # 現在時刻取得
    now = Time.zone.now

    # 延長チェック
    # TODO: 延長可決なら更新期限を延長して処理終了
    # TODO: Regulation モジュールに延長時間計算処理を実装

    # 早回しチェック
    # TODO: 早回し可決なら更新期限を now に変更

    # 更新期限チェック
    raise ActiveRecord::Rollback if @table.period > now

    # 開始・廃卓チェック
    return update_created_table_status if @table.status_created?

    # 終了卓閉鎖チェック
    return update_closed_table_status if @table.settled?

    # プレイ中
    update_live_table_status
  end

  def update_created_table_status
    # ロビー
    # TODO: 参加者が揃っていなければ終了
    unless @table.full?
      @table.discard
      @table.save!
      return
    end

    # TODO: 参加者に担当国をアサイン

    # 開始
    @table.start
    @table.save!
  end

  def update_live_table_status
    return proceed_phase_1st if @table.phase_1st?
    return proceed_phase_2nd if @table.phase_2nd?
    return proceed_phase_3rd if @table.phase_3rd?
  end

  def proceed_phase_1st
    # 和平チェック
    return if peace?

    # 維持命令生成
    create_hold_orders_for_neglected_units

    # 仮想命令削除
    delete_assumed_orders

    # 行軍命令解決
    keepout = resolute_orders_and_save

    dislodged_units = @table.last_phase_units.where.not(keepout: nil)
    if dislodged_units.empty?
      # 敗退ユニットがなければ継続して次フェイズの処理を実行
      proceed_phase_2nd
    else
      # 解散命令生成
      create_retreat_orders_for_dislodged_units(dislodged_units, keepout)
    end
  end

  def create_hold_orders_for_neglected_units
    turn = @table.current_turn
    @table.last_phase_units.each do |unit|
      next unless unit.orders.where(power: unit.power).empty?

      turn.orders << ListPossibleOrdersService.call(
        turn: turn,
        unit: unit,
        power: unit.power
      ).detect(&:hold?)
    end
  end

  def delete_assumed_orders
    turn = @table.current_turn
    turn.orders.where(phase: @table.phase).map do |order|
      order.delete if order.assumed?
    end
  end

  def resolute_orders_and_save
    turn = @table.current_turn
    _result, keepout = ResoluteOrdersService.call(
      orders: turn.orders.where(phase: @table.phase)
    )

    # ユニット配置を確定して次のフェイズに進める
    @table = ArrangeUnitsService.call(table: @table)
    @table = @table.proceed
    @table.save!
    keepout
  end

  def create_retreat_orders_for_dislodged_units(dislodged_units, keepout)
    turn = @table.current_turn
    dislodged_units.each do |unit|
      order = ListPossibleRetreatsService.call(
        turn: turn,
        power: unit.power,
        unit: unit,
        standoff: keepout
      ).detect(&:disband?)
      turn.orders << order
    end
  end

  def proceed_phase_2nd
    turn = @table.current_turn

    # 撤退解散命令解決
    retreat_orders = turn.orders.where(phase: @table.phase)
    ResoluteRetreatsService.call(orders: retreat_orders)

    # ユニット保存
    @table = ArrangeUnitsService.call(table: @table)
    @table.save!

    # 春撤退フェイズであれば秋外交フェイズに進み更新終了
    if @table.phase_spr_2nd?
      @table = @table.proceed
      return
    end

    # 秋撤退フェイズであれば占領処理と制覇チェックを行う
    # 前年の秋撤退フェイズから領地情報を取得
    last_turn = @table.turns.find_by(number: @table.turn - 1)
    last_turn.provinces.each do |province|
      turn.provinces << province.dup
    end

    # 占領処理
    turn.units.where(phase: @table.phase).each do |unit|
      province = turn.provinces.find_by(code: unit.prov_key)
      unless province
        # 中立地域の占領
        params = MapUtil.provinces[unit.prov_key]
        params['code'] = unit.prov_key
        province = turn.provinces.build(params)
      end
      province.power = unit.power.symbol
      province.save!
    end

    # 滅亡処理
    supply_centers = turn.provinces.where(supplycenter: true)
    @table.powers.each do |power|
      next unless supply_centers.where(power: power.symbol).empty?

      # 滅亡した国の全ての領土を解放
      turn.provinces.where(power: power.symbol).delete_all
      # 滅亡した国の全てのユニットを撤去
      turn.units.where(phase: @table.phase).where(power: power).delete_all
    end
    turn.save!

    # 制覇チェック
    return if solo?

    # 秋調整フェイズに進む
    @table = @table.proceed

    # 調整フェイズスキップ判定
    to_gain = false
    to_lose = false
    @table.powers.each do |power|
      next if power.symbol == 'x'

      provinces = turn.provinces
                      .where(power: power.symbol)
                      .where(supplycenter: true)
      units = @table.last_phase_units.where(power: power)
      # 滅亡している：調整不要
      next if provinces.empty?
      # ユニット数と補給都市数が一致している：調整不要
      next if provinces.size == units.size

      if provinces.size > units.size
        homes = MapUtil.provinces.select do |_p, v|
          v['supplycenter'] && v['owner'] == power.symbol
        end .keys
        homes.each do |province|
          next unless units.where('province like ?', "#{province}%").empty?

          # ユニットより補給都市が多く本国補給都市に空きがある：増設可
          to_gain = true
          break
        end
        next
      end

      # ユニットより補給都市が少ない：要撤去
      to_lose = true
      # 撤去命令登録
      unit_provinces = PrioritizeDisbandingService.call(
        table: @table,
        power: power
      )
      (units.size - provinces.size).downto(0) do
        break if unit_provinces.empty?

        province = unit_provinces.pop
        unit = @table.last_phase_units
                     .where('province like ?', "#{province}%").first
        turn.orders << DisbandOrder.new(power: power, unit: unit)
      end
      # turn.orders.each { |o| p o }
    end
    # 要調整
    return if to_gain || to_lose

    proceed_phase_3rd
  end

  def proceed_phase_3rd
    # TODO: 増設撤去実行
    # TODO: ユニット保存

    # 次のフェイズに進む
    @table = @table.proceed
  end

  def update_closed_table_status
    # 感想戦
    # 卓を閉鎖
    @table = @table.close
    @table.save!
  end

  def peace?
    # if false
    #   @table = @table.draw
    #   break
    # end
    false
  end

  def solo?
    winner = nil
    supply_centers = @table.current_turn.provinces.where(supplycenter: true)
    @table.powers.each do |power|
      next if supply_centers.where(power: power.symbol).size < Const.solo_line

      winner = power
      break
    end
    return false unless winner

    @table = @table.solo
    true
  end
end
