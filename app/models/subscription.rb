# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  enum plan: { free: "free", pro: "pro", enterprise: "enterprise" }
  enum status: { inactive: "inactive", active: "active", cancelled: "cancelled", expired: "expired" }

  PLANS = {
    pro: { amount: 49900, currency: "INR", label: "Pro — Rs 499/mo" },
    enterprise: { amount: 149900, currency: "INR", label: "Enterprise — Rs 1499/mo" }
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
