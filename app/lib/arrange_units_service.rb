# frozen_string_literal: true

class ArrangeUnitsService
  def self.call(table:)
    new(table: table).call
  end

  def initialize(table:)
    @table = table
  end

  def call
    turn = @table.current_turn

    # 前処理
    if @table.phase_spr_2nd? || @table.phase_fal_2nd?
      # 前フェイズの撃退されていないユニットを複製
      @table.last_phase_units.where(keepout: nil).each do |lpu|
        unit = lpu.dup
        unit.phase = @table.phase
        turn.units << unit
      end
    elsif @table.phase_fal_3rd?
      # 前フェイズの全てのユニットを複製
      @table.last_phase_units.each do |lpu|
        unit = lpu.dup
        unit.phase = @table.phase
        turn.units << unit
      end
    end

    turn.orders.where(phase: @table.phase).each do |order|
      # 仮想命令は除外
      next unless order.power == order.unit.power

      # 命令結果によるユニット配置
      if @table.phase_spr_1st? || @table.phase_fal_1st?
        # 撃退された命令
        if order.dislodged?
          params = {}
          params[:type] = order.unit.type
          params[:power] = order.unit.power
          params[:phase] = @table.phase
          params[:province] = order.unit.province
          unit = turn.units.build(params)
          unit.keepout = order.keepout
          unit.save!
          next
        end

        # 撃退されなかった維持・支援・輸送命令
        if order.hold? || order.support? || order.convoy?
          params = {}
          params[:type] = order.unit.type
          params[:power] = order.unit.power
          params[:phase] = @table.phase
          params[:province] = order.unit.province
          turn.units.create(params)
          next
        end

        # 移動命令
        if order.move?
          if order.succeeded?
            # 成功
            params = {}
            params[:type] = order.unit.type
            params[:power] = order.unit.power
            params[:phase] = @table.phase
            params[:province] = order.dest
            turn.units.create(params)
          else
            # 失敗
            params = {}
            params[:type] = order.unit.type
            params[:power] = order.unit.power
            params[:phase] = @table.phase
            params[:province] = order.unit.province
            turn.units.create(params)
          end
          next
        end
      elsif @table.phase_spr_2nd? || @table.phase_fal_2nd?
        # 成功した撤退命令
        if order.retreat? && order.succeeded?
          params = {}
          params[:type] = order.unit.type
          params[:power] = order.unit.power
          params[:phase] = @table.phase
          params[:province] = order.dest
          turn.units.create(params)
          next
        end

        # 解散命令は何もしない
        nil if order.disband?
      end
    end

    @table
  end
end
