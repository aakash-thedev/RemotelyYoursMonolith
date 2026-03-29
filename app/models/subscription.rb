# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  enum plan: { free: "free", pro: "pro", pro_plus: "pro_plus" }
  enum status: { inactive: "inactive", active: "active", cancelled: "cancelled", expired: "expired" }

  PLANS = {
    pro: { amount: 89_900, currency: "INR", label: "Pro", price_display: "₹899/year", duration: 1.year },
    pro_plus: { amount: 249_900, currency: "INR", label: "Pro+", price_display: "₹2,499/year", duration: 1.year }
  }.freeze

  scope :active_subscriptions, -> { where(status: :active).where("expires_at > ?", Time.current) }

  def days_remaining
    return 0 unless expires_at.present?
    [(expires_at.to_date - Date.current).to_i, 0].max
  end

  def renewable?
    active? && days_remaining <= 7
  end
end
