# 第1問：デメテルの法則を突破せよ（尋ねるな、命じろ）
# ECサイトの注文コントローラの一部です。current_user から cart、さらに items と奥まで手を伸ばして判断している「スパイ」のようなコードをリファクタリングしてください。

# 【リファクタリング前】
# Ruby
class OrdersController < ApplicationController
  def create
    # 相手の内部構造（cartやitems）を詳しく知りすぎていて、自分で判断している
    if current_user.cart.items.any? && current_user.cart.total_price > 0
      @order = Order.create!(user: current_user, amount: current_user.cart.total_price)
      current_user.cart.items.destroy_all
      redirect_to @order, notice: "注文が完了しました"
    else
      redirect_to cart_path, alert: "カートが空です"
    end
  end
end
# 課題: User モデルや Cart モデルにどのようなメソッドを作れば、コントローラは「注文して！」と命じるだけで済むようになりますか？

class OrdersController < ApplicationController
  def create
    cart = Cart.new(current_user)

    if (@order = cart.order_items)
      redirect_to @order, notice: "注文が完了しました"
    else
      redirect_to cart_path, alert: "カートが空です"
    end
  end
end

class Cart

  attr_reader :user

  def initialize(user)
    @user = user
    self.freeze
  end

  def order_items
    nil unless can_checkout?

    Order.transaction do
      order = Order.create!(user: user, amount: total_price)
      user.cart_items.destroy_all
      order
    end
  end

  private
  def can_checkout?
    user.cart_items.any? && total_price > 0
  end

  def total_price
    user.cart_items.sum(:price)
  end
end


