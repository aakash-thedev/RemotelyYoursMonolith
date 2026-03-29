# frozen_string_literal: true

class WeeklyDigestWorker
  include Sidekiq::Worker

  sidekiq_options queue: "mailers", retry: 2

  def perform
    Rails.logger.info("[WeeklyDigestWorker] Starting weekly digest delivery...")

    users_with_matches = User
      .joins(:profile, :subscription)
      .where(subscriptions: { plan: %w[pro pro_plus], status: "active" })
      .distinct

    sent_count = 0

    users_with_matches.find_each do |user|
      matches = user.job_matches
        .includes(:job)
        .where("scored_at >= ?", 7.days.ago)
        .order(fit_score: :desc)
        .limit(10)

      next if matches.empty?

      DigestMailer.weekly_digest(user: user, matches: matches).deliver_later
      sent_count += 1
    end

    Rails.logger.info("[WeeklyDigestWorker] Queued #{sent_count} digest emails")
  end
end
