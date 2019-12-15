class ResoluteRetreatsService
  def self.call(orders:)
    self.new(orders: orders).call
  end

  def initialize(orders:)
    @orders = orders.to_a
  end

  def call
    # 解隊命令解決
    @orders.select { |o| o.disband? }.map { |d| d.succeed }

    # 撤退命令解決
    dests = @orders.select { |o| o.retreat? }.map { |r| r.dest }.uniq
    dests.each do |dest|
      retreats = @orders.select { |o| o.retreat? && o.dest == dest }
      if retreats.size > 1
        # 撤退先競合のため解隊
        retreats.map { |r| r.fail }
        next
      end

      # 撤退成功
      retreats[0].succeed
    end
    return @orders
  end
end
