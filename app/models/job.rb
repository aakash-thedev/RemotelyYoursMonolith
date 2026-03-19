# frozen_string_literal: true

class Job < ApplicationRecord
  has_many :job_matches, dependent: :destroy

  validates :title, presence: true
  validates :external_id, uniqueness: { scope: :source }, allow_nil: true

  scope :active, -> { where(is_active: true) }
  scope :recent, -> { where("posted_at >= ?", 14.days.ago) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def salary_range
    return nil unless salary_min.present? || salary_max.present?
    "#{salary_min || '?'}–#{salary_max || '?'} #{salary_currency || 'USD'}"
  end
end
