class GoldCustomerPolicy
  def self.gold?(history)
    # 3つの条件が密結合している
    history.total_amount >= 100_000 &&
      history.purchase_frequency_per_month >= 10 &&
      history.return_rate <= 0.001
  end
end


# --------------------

class AmountRule
  def satisfied_by?(history)
    history.total_amount >= 100_000
  end
end

class FrequencyRule
  def satisfied_by?(history)
    history.purchase_frequency_per_month >= 10
  end
end

class ReturnRateRule
  def satisfied_by?(history)
    history.return_rate <= 0.001
  end
end


class GoldCustomerPolicy
  def initialize
    @rules = [
      AmountRule.new,
      FrequencyRule.new,
      ReturnRateRule.new,
    ]
  end

  def gold?(history)
    @rules.all? { |rule| rule.satisfied_by?(history) }
  end
end

class CampaignService
  def apply_gold_benefit(member)
    policy = GoldCustomerPolicy.new

    if policy.gold?(member.purchase_history)
      # 成功した時のビジネスロジック（例：ポイント付与）
      member.grant_special_points(1000)
    else
      Rails.logger.info "Member #{member.id} はゴールド条件を満たしませんでした"
    end
  end
end