# frozen_string_literal: true

class UpdateSubscriptionPlans < ActiveRecord::Migration[7.0]
  def up
    # Rename enterprise plan to pro_plus
    execute "UPDATE subscriptions SET plan = 'pro_plus' WHERE plan = 'enterprise'"
  end

  def down
    execute "UPDATE subscriptions SET plan = 'enterprise' WHERE plan = 'pro_plus'"
  end
end
