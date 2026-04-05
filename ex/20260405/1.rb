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
    @current_cart = Cart.new(current_user)
    redirect_to cart_path, alert: "カートが空です" if current_cart

    @current_cart.order_items
    redirect_to @order, notice: "注文が完了しました"
  end
end

class Cart < ActiveRecord::Base
  def initialize(current_user)
    if current_user.cart.items.any? && current_user.cart.total_price < 0
      raise  "カートが空です"
    end

    @current_user = current_user

    self.freeze

  end

  def order_items
    Order.create!(user: current_user, amount: current_user.cart.total_price)
    current_user.cart.items.destroy_all
  end
end


