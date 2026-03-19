# frozen_string_literal: true

class JobMatch < ApplicationRecord
  belongs_to :user
  belongs_to :job

  validates :user_id, uniqueness: { scope: :job_id, message: "already has a match for this job" }
  validates :fit_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  scope :high_scoring, -> { where("fit_score >= ?", 70) }
  scope :scored, -> { where.not(fit_score: nil) }
  scope :unscored, -> { where(fit_score: nil) }

  # score_breakdown is stored as JSON:
  # { skills: 85, experience: 70, role_fit: 90, location: 80 }

  def strong_match?
    fit_score.present? && fit_score >= 75
  end
end
