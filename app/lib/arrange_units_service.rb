# frozen_string_literal: true

class ArrangeUnitsService
  def self.call(table:)
    new(table: table).call
  end

  def initialize(table:)
    @table = table
  end

  def call
    if @table.phase_spr_1st? || @table.phase_fal_1st?
      arrange_units_1st_phase

    elsif @table.phase_spr_2nd? || @table.phase_fal_2nd?
      arrange_units_2nd_phase

    elsif @table.phase_fal_3rd?
      arrange_units_3rd_phase

    else
      raise Exception, 'Illegal case'
    end
  end

  # 外交フェイズ
  def arrange_units_1st_phase
    # 命令結果に基づくユニット配置（仮想命令を除外）
    orders = @table.current_turn.orders
                   .where(phase: @table.phase)
                   .reject(&:assumed?)
    orders.each do |order|
      # 撃退された命令に基づくユニット配置
      next arrange_dislodged_units(order) if order.dislodged?

      # 撃退されなかった維持・支援・輸送命令に基づくユニット配置
      next arrange_alived_unmoved_units(order) unless order.move?

      # 成功した移動命令に基づくユニット配置
      next arrange_succeeded_move_units(order) if order.succeeded?

      # 失敗した移動命令に基づくユニット配置
      next arrange_failed_move_units(order)
    end

    @table
  end

  def arrange_dislodged_units(order)
    unit = @table.current_turn.units.build(
      type: order.unit.type,
      power: order.unit.power,
      phase: @table.phase,
      province: order.from
    )
    unit.keepout = order.keepout
    unit.save!
  end

  def arrange_alived_unmoved_units(order)
    @table.current_turn.units.create(
      type: order.unit.type,
      power: order.unit.power,
      phase: @table.phase,
      province: order.from
    )
  end

  def arrange_succeeded_move_units(order)
    @table.current_turn.units.create(
      type: order.unit.type,
      power: order.unit.power,
      phase: @table.phase,
      province: order.dest
    )
  end

  def arrange_failed_move_units(order)
    @table.current_turn.units.create(
      type: order.unit.type,
      power: order.unit.power,
      phase: @table.phase,
      province: order.from
    )
  end

  # 撤退フェイズ
  def arrange_units_2nd_phase
    # 前フェイズの撃退されていないユニットを複製
    duplicate_lastphase_alived_units

    # 命令結果に基づくユニット配置（仮想命令は存在しない）
    orders = @table.current_turn.orders.where(phase: @table.phase)
    orders.where(phase: @table.phase).each do |order|
      # 成功した撤退命令
      if order.retreat? && order.succeeded?
        next arrange_succeeded_retreated_units(order)
      end

      # 解散命令は何もしない
      nil if order.disband?
    end
    @table
  end

  def duplicate_lastphase_alived_units
    @table.last_phase_units.where(keepout: nil).each do |lpu|
      unit = lpu.dup
      unit.phase = @table.phase
      @table.current_turn.units << unit
    end
  end

  def arrange_succeeded_retreated_units(order)
    @table.current_turn.units.create(
      type: order.unit.type,
      power: order.unit.power,
      phase: @table.phase,
      province: order.dest
    )
  end

  # 調整フェイズ
  def arrange_units_3rd_phase
    # 前フェイズの全てのユニットを複製
    @table.last_phase_units.each do |lpu|
      unit = lpu.dup
      unit.phase = @table.phase
      @table.current_turn.units << unit
    end
    @table
  end
end
