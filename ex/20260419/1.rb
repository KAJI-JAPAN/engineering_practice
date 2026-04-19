# --- 修正対象のクラス ---
class FieldManager
  # 1. 指定した名前のアイテムを持っているかチェックする
  # 【問題：Rubyの強力なメソッドを知らずに、わざわざループを回している】
  def has_item?(items, item_name)
    result = false
    items.each do |item|
      if item.name == item_name
        result = true
        break
      end
    end
    result
  end

  # 2. 毒状態のメンバーにダメージを与える
  # 【問題：if文が重なっていて見通しが悪い】
  def process_poison_damage(members)
    members.each do |member|
      if member.hit_point > 0
        if member.poisoned?
          member.hit_point -= 10
          if member.hit_point <= 0
            member.hit_point = 0
            member.die
          end
        end
      end
    end
  end

  # 3. パーティに新メンバーを追加する
  # 【問題：配列操作の知識がManager側に漏れ出している（低凝集）】
  def add_member(members, new_member)
    if members.size >= 4
      raise "パーティがいっぱいです"
    end

    # 重複チェックも自前でループ
    already_exists = false
    members.each do |m|
      already_exists = true if m.id == new_member.id
    end
    raise "既にパーティにいます" if already_exists

    members << new_member
  end
end

# --- 補助クラス (これらは変更しなくてOKです) ---
class Item
  attr_reader :name
  def initialize(name) ; @name = name ; end
end

class Member
  attr_accessor :id, :hit_point, :is_poisoned, :is_dead
  def initialize(id, hp) ; @id = id; @hit_point = hp; @is_poisoned = false; @is_dead = false ; end
  def poisoned? ; @is_poisoned ; end
  def die ; @is_dead = true ; end
end

# ---------------------------------------

# --- 修正対象のクラス ---
class Party
  MAX_MEMBER_COUNT = 4

  def initialize(members = [])
    @members = members.dup.freeze
  end

    # 1. 指定した名前のアイテムを持っているかチェックする
  # 【問題：Rubyの強力なメソッドを知らずに、わざわざループを回している】
  def has_item?(items, item_name)
    items.any? { |i| i.name == item_name }
  end

  # 2. 毒状態のメンバーにダメージを与える
  # 【問題：if文が重なっていて見通しが悪い】
  def process_poison_damage()
    @members.each do |member|
      next unless member.alive?
      next unless member.poisoned?
      member.hit_point -= 10
      if member.hit_point <= 0
        member.hit_point = 0
        member.die
      end
    end
  end

  # 3. パーティに新メンバーを追加する
  # 【問題：配列操作の知識がManager側に漏れ出している（低凝集）】
  def add_member(new_member)
    raise "パーティがいっぱいです" if full?

    raise "既にパーティにいます" if exists?(new_member)

    adding_member = @members.dup
    adding_member << new_member

    self.class.new(adding_member)
  end

  def full?
    @members.size == MAX_MEMBER_COUNT
  end

  def exists?(member)
    @members.any? { |m| m.id == member.id }
  end

  private


end

# --- 補助クラス (これらは変更しなくてOKです) ---
class Item
  attr_reader :name
  def initialize(name) ; @name = name ; end
end

class Member
  attr_accessor :id, :hit_point, :is_poisoned, :is_dead
  def initialize(id, hp) ; @id = id; @hit_point = hp; @is_poisoned = false; @is_dead = false ; end
  def poisoned? ; @is_poisoned ; end
  def die ; @is_dead = true ; end
end