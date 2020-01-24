# frozen_string_literal: true

class ResoluteOrdersService
  def self.call(orders:)
    new(orders: orders).call
  end

  def initialize(orders:)
    @orders = orders.to_a
    @standoff = []
  end

  def call
    # ステータス初期化
    initialize_status

    # 無効支援除外
    remove_unmatched_support_orders

    # 支援カット判定
    resolute_cutting_support_orders

    # 支援適用
    apply_support_orders

    # 輸送適用
    apply_convoy_orders

    # 交換移動命令解決
    resolute_switch_orders

    # 輸送妨害の優先解決
    resolute_disturb_convoy_orders

    # 支援妨害の優先解決
    resolute_disturb_support_orders

    # その他移動命令解決
    resolute_other_move_orders

    # 未処理維持命令成功判定
    resolute_hold_orders

    [@orders, @standoff]
  end

  private

  # ステータス初期化
  def initialize_status
    @orders.each do |o|
      o.unslove
      o.supports = 0
      o.keepout = nil
    end
  end

  # 無効支援除外
  def remove_unmatched_support_orders
    supports = unsloved_support_orders
    supports.each do |s|
      s.unmatch unless @orders.detect { |o| o.to_key == s.target }
    end
  end

  # 支援カット判定
  def resolute_cutting_support_orders
    # 複数個所からの攻撃は即カット
    resolute_cutting_support_orders_multiple_attack

    # 移動命令の支援でなければ攻撃を受けた時点でカット
    resolute_cutting_support_orders_not_move_target

    # 遠隔攻撃でなければカット
    resolute_cutting_support_orders_attacked_by_directly

    # 支援対象の移動命令に攻撃目標がいなければカット
    resolute_cutting_support_orders_not_support_attack

    # 攻撃支援目標が輸送海軍でなければカット
    resolute_cutting_support_orders_not_support_attacking_convoy

    # 攻撃支援目標の輸送対象が自身でなければカット
    resolute_cutting_support_orders_not_attacked_by_convoyed_target

    # 攻撃支援目標の輸送海軍を除去しても輸送経路が寸断されなければカット
    resolute_cutting_support_orders_oversea_attack
  end

  def effected_support_cutter(support)
    enemies = unsloved_move_orders_support_cutter(support)
    return nil if enemies.empty?

    # 支援対象の攻撃目標にはカットされない
    enemy = enemies[0]
    support_target = @orders.detect { |o| o.to_key == support.target }
    return nil if support_target.dest == enemy.unit.province

    enemy
  end

  def resolute_cutting_support_orders_multiple_attack
    unsloved_support_orders.each do |support|
      enemies = unsloved_move_orders_support_cutter(support)
      if enemies.size > 1
        support.cut
        next
      end
    end
  end

  def resolute_cutting_support_orders_not_move_target
    unsloved_support_orders.each do |s|
      next unless effected_support_cutter(s)

      support_target = @orders.detect { |o| o.to_key == s.target }
      unless support_target.move?
        s.cut
        next
      end
    end
  end

  def resolute_cutting_support_orders_attacked_by_directly
    unsloved_support_orders.each do |s|
      next unless (enemy = effected_support_cutter(s))
      next unless MapUtil.adjacents[s.unit.province][enemy.unit.province]

      s.cut
      next
    end
  end

  def resolute_cutting_support_orders_not_support_attack
    unsloved_support_orders.each do |s|
      next unless effected_support_cutter(s)

      support_target = supported_order_by(s)
      attack_target = attack_target_by(support_target)
      next if attack_target

      s.cut
      next
    end
  end

  def resolute_cutting_support_orders_not_support_attacking_convoy
    unsloved_support_orders.each do |s|
      next unless effected_support_cutter(s)

      support_target = supported_order_by(s)
      attack_target = attack_target_by(support_target)
      unless attack_target.convoy?
        s.cut
        next
      end
    end
  end

  def resolute_cutting_support_orders_not_attacked_by_convoyed_target
    unsloved_support_orders.each do |s|
      next unless (enemy = effected_support_cutter(s))

      support_target = supported_order_by(s)
      attack_target = attack_target_by(support_target)

      unless enemy.to_key == attack_target.target
        s.cut
        next
      end
    end
  end

  def resolute_cutting_support_orders_oversea_attack
    unsloved_support_orders.each do |s|
      next unless (enemy = effected_support_cutter(s))

      support_target = supported_order_by(s)
      attack_target = attack_target_by(support_target)

      convoys = unsloved_convoy_orders
                .select { |o| o.target == enemy.to_key }
                .reject { |c| c == attack_target }
      next unless alive_any_convoy_route_for(enemy, convoys)

      s.cut
    end
  end

  def alive_any_convoy_route_for(enemy, convoys)
    SearchReachableCoastalsService.call(
      unit: enemy.unit,
      fleets: convoys.map(&:unit)
    ).include?(enemy.dest)
  end

  # 支援適用
  def apply_support_orders
    supports = unsloved_support_orders
    supports.each do |s|
      target = @orders.detect { |o| o.to_key == s.target }
      if target
        target.supports += 1
        s.apply
      else
        s.reject
      end
    end
  end

  # 輸送適用
  def apply_convoy_orders
    # 輸送経路成立チェック
    apply_convoy_orders_check_route

    # 輸送経路不成立の輸送対象移動命令のリジェクト
    apply_convoy_orders_reject_impossible
  end

  def apply_convoy_orders_check_route
    unsloved_move_orders.each do |m|
      convoys = unsloved_convoy_orders
      next if convoys.empty?

      coastals = SearchReachableCoastalsService.call(
        unit: m.unit,
        fleets: convoys.map(&:unit)
      )
      if coastals.include?(m.dest)
        # 経路成立
        convoys.each(&:apply)
      else
        # 経路不成立
        convoys.each(&:reject)
      end
    end
  end

  def apply_convoy_orders_reject_impossible
    unsloved_move_orders_to_armies_on_coastal.each do |m|
      dest = (MapUtil.adjacents[m.unit.province][m.dest])
      # 陸路で移動可能
      next if dest && dest[m.unit.type.downcase]
      # 他の海路が生きている
      next if sea_route_effective?(move: m)

      m.reject
    end
  end

  # 交換移動命令解決
  def resolute_switch_orders
    dests = unsloved_move_orders.map(&:dest).uniq
    return if dests.empty?

    dests.each do |dest|
      move = unsloved_move_orders_to(dest).first
      next unless move
      next if sea_route_effective?(move: move)

      against = unsloved_move_orders_against(move)
      next unless against
      next if sea_route_effective?(move: against)

      resolute_switch_orders_status(move, against)
    end
  end

  def resolute_switch_orders_status(move, against)
    if move.supports > against.supports
      move.succeed
      against.dislodge(against: move)
    elsif move.supports < against.supports
      move.dislodge(against: against)
      against.succeed
    else
      move.fail
      against.fail
    end
  end

  # 輸送妨害の優先解決
  def resolute_disturb_convoy_orders
    @orders.select(&:convoy?).map { |c| c.unit.province }.each do |dest|
      resolute_move_orders_core(dest: dest)
    end

    unsloved_move_orders.each do |move|
      convoys = @orders.select do |o|
        o.convoy? && o.applied? && o.target == move.to_key
      end

      resolute_disturb_convoy_orders_succeed(convoys, move)
    end
  end

  def resolute_disturb_convoy_orders_succeed(convoys, move)
    return if convoys.empty?

    coastals = SearchReachableCoastalsService.call(
      unit: move.unit,
      fleets: convoys.map(&:unit)
    )
    move.fail unless coastals.include?(move.dest)
  end

  # 支援妨害の優先解決
  def resolute_disturb_support_orders
    dests = @orders.select(&:support?).map { |s| s.unit.province }
    return if dests.empty?

    dests.each do |dest|
      # 移動命令解決
      resolute_move_orders_core(dest: dest)
    end
  end

  # その他移動命令解決
  def resolute_other_move_orders
    loop do
      dests = unsloved_move_orders.map(&:dest).uniq
      break if dests.empty?

      dests.each do |dest|
        # 移動命令解決
        resolute_move_orders_core(dest: dest)
      end
    end
  end

  # 未処理維持命令成功判定
  def resolute_hold_orders
    holds = @orders.select { |o| o.hold? && o.unsloved? }
    holds.each(&:succeed)
  end

  def resolute_move_orders_core(dest:)
    moves = unsloved_move_orders_to(dest)
    return if moves.empty?

    # 複数の衝突
    if moves.size > 1
      resolute_move_orders_conflict(moves, dest)
      return
    end

    # 入ってます
    move = moves[0]
    hold = hold_orders_on(dest)

    # 暫定成功
    unless hold
      move.succeed
      return
    end

    # 移動先と同じ軍からの支援をリジェクト
    resolute_move_orders_reject_supports(move, hold)

    # 移動失敗
    if condition_failure_move(move, hold)
      resolute_move_orders_failure(move, hold)
      return
    end

    # 移動成功
    resolute_move_orders_succeed_move(move, hold)

    return unless hold.support?

    # 撃退されたのが支援命令だった場合
    resolute_move_orders_reset_supported_by_dislodged_unit(hold)
  end

  def resolute_move_orders_conflict(moves, dest)
    support_level_list = moves.map(&:supports)
    max_support_level = support_level_list.max
    if support_level_list.count(max_support_level) == 1
      winner = moves.detect { |m| m.supports == max_support_level }
    end
    moves.map do |m|
      next if winner && m == winner

      m.fail
      against = rewind_move_order_to(province: m.unit.province)
      m.dislodge(against: against) if against
    end
    @standoff << dest unless winner
  end

  def resolute_move_orders_reject_supports(move, hold)
    @orders.select { |o| o.support? && o.target == move.to_key }.each do |s|
      next unless s.power == hold.power

      s.reject
      move.supports -= 1
    end
  end

  def resolute_move_orders_failure(move, hold)
    move.fail
    @orders.select { |o| o.support? && o.target == move.to_key }.each do |s|
      next unless move.power == hold.power

      s.reject
    end

    against = rewind_move_order_to(province: move.unit.province)
    move.dislodge(against: against) if against
  end

  def resolute_move_orders_reset_supported_by_dislodged_unit(hold)
    target = @orders.detect { |o| o.to_key == hold.target }
    return unless target

    target.unslove
    target.supports -= 1
    return unless target.dest

    @orders.select { |o| o.move? && o.dest == target.dest }.each do |m|
      m.unslove unless m == target
    end
  end

  def resolute_move_orders_succeed_move(move, hold = nil)
    move.succeed
    hold&.dislodge(against: move)
  end

  # 海路有効判定
  def sea_route_effective?(move:)
    convoys = applied_convoy_orders.select { |c| c.target == move.to_key }
    fleets = convoys.map(&:unit)
    coastals = SearchReachableCoastalsService.call(
      unit: move.unit,
      fleets: fleets
    )
    coastals.include?(move.dest)
  end

  def rewind_move_order_to(province:)
    against_move = @orders.detect { |o| o.dest == province && o.succeeded? }
    return nil unless against_move

    if against_move&.supports&.positive?
      against_move.succeed
      return against_move
    end
    against_move.unslove
    nil
  end

  def hold_orders
    holds = @orders.reject(&:move?)
    holds += @orders.select { |o| o.move? && (o.failed? || o.dislodged?) }
    holds
  end

  def hold_orders_on(dest)
    hold_orders.detect { |h| h.unit.province == dest }
  end

  def unsloved_move_orders
    @orders.select { |o| o.move? && o.unsloved? }
  end

  def unsloved_move_orders_to(dest)
    unsloved_move_orders.select { |m| m.dest == dest }
  end

  def unsloved_move_orders_against(move)
    unsloved_move_orders
      .select { |m| m.dest == move.unit.province }
      .detect { |m| m.unit.province == move.dest }
  end

  def unsloved_move_orders_to_armies_on_coastal
    unsloved_move_orders
      .select { |m| m.unit.army? }
      .select { |m| MapUtil.coastal?(m.unit.province) }
  end

  def unsloved_move_orders_support_cutter(support)
    unsloved_move_orders
      .select { |m| support.unit.province == m.dest }
      .reject { |m| m.power == support.power }
  end

  def unsloved_support_orders
    @orders.select { |o| o.support? && o.unsloved? }
  end

  def unsloved_convoy_orders
    @orders.select { |o| o.convoy? && o.unsloved? }
  end

  def applied_convoy_orders
    @orders.select { |o| o.convoy? && o.applied? }
  end

  def condition_failure_move(move, hold)
    hold.supports >= move.supports || hold.power == move.power
  end

  def supported_order_by(support)
    @orders.detect { |o| o.to_key == support.target }
  end

  def attack_target_by(support_target)
    @orders.detect do |o|
      o.unit.province == support_target.dest
    end
  end
end
