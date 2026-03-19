# frozen_string_literal: true

module Notifications
  class DigestMailerService
    # Sends a weekly digest email to users with their top job matches.
    #
    # Usage:
    #   Notifications::DigestMailerService.new(user).call
    #   Notifications::DigestMailerService.send_all_digests  # for all eligible users

    def initialize(user)
      @user = user
    end

    def call
      return unless eligible_for_digest?

      top_matches = @user.job_matches
        .scored
        .high_scoring
        .includes(:job)
        .order(fit_score: :desc)
        .limit(10)

      return if top_matches.empty?

      DigestMailer.weekly_digest(
        user: @user,
        matches: top_matches
      ).deliver_later

      Rails.logger.info("[DigestMailerService] Queued digest for #{@user.email} with #{top_matches.size} matches")

      { user_id: @user.id, matches_count: top_matches.size, status: "queued" }
    rescue StandardError => e
      Rails.logger.error("[DigestMailerService] Failed for #{@user.email}: #{e.message}")
      { user_id: @user.id, status: "failed", error: e.message }
    end

    def self.send_all_digests
      eligible_users = User.joins(:profile, :job_matches)
        .where(job_matches: { fit_score: 70.. })
        .distinct

      results = eligible_users.find_each.map do |user|
        new(user).call
      end.compact

      Rails.logger.info("[DigestMailerService] Sent #{results.size} digests")
      results
    end

    private

    def eligible_for_digest?
      @user.profile.present? && @user.job_matches.scored.any?
    end
  end
end
