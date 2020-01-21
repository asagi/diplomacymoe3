# frozen_string_literal: true

class ResoluteRetreatsService
  def self.call(orders:)
    new(orders: orders).call
  end

  def initialize(orders:)
    @orders = orders.to_a
  end

  def call
    # 解隊命令解決
    @orders.select(&:disband?).map(&:succeed)

    # 撤退命令解決
    dests = @orders.select(&:retreat?).map(&:dest).uniq
    dests.each do |dest|
      retreats = @orders.select { |o| o.retreat? && o.dest == dest }
      if retreats.size > 1
        # 撤退先競合のため解隊
        retreats.map(&:fail)
        next
      end

      # 撤退成功
      retreats[0].succeed
    end
    @orders
  end
end
