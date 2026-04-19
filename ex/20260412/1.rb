class ShippingCalculator
  def calculate(order)
    case order.shipping_method
    when :standard
      order.weight * 500
    when :express
      order.weight * 800 + 1000
    when :international
      order.weight * 2000 + 5000
      # 新しい配送方法が増えるたびに、ここに case を追加し続けなければならない...
    else
      raise "Unknown method"
    end
  end
end

# ----------------------------------------------------


class Shipping
  def calculate
    raise "Unknown method"
  end
end

class StandardShipping < Shipping
  def initialize(order)
    @order = order
  end
  def calculate
    @order.weight * 500
  end
end

class ExpressShipping < Shipping
  def initialize(order)
    @order = order
  end
  def calculate
    @order.weight * 800 + 1000
  end
end

class InternationalShipping < Shipping
  def initialize(order)
    @order = order
  end
  def calculate
    @order.weight * 2000 + 5000
  end
end


class ShipService
  SIPPING_METHODS = {
    standard: StandardShipping,
    economy: ExpressShipping,
    international: InternationalShipping,
  }.freeze

  def self.calculate(order)
    klass = SIPPING_METHODS[order.shipping_method.to_sym]
    raise "Unknown method" unless klass

    strategy = klass.new(order)
    strategy.calculate
  end
end