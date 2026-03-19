# frozen_string_literal: true

class FitScoreWorker
  include Sidekiq::Worker

  sidekiq_options queue: "scoring", retry: 2

  def perform(user_id, job_id)
    user = User.find(user_id)
    job = Job.find(job_id)
    profile = user.profile

    unless profile&.profile_complete?
      Rails.logger.warn("[FitScoreWorker] Skipping user #{user_id} — incomplete profile")
      return
    end

    result = Ai::FitScorer.new(profile, job).call

    match = JobMatch.find_or_initialize_by(user_id: user_id, job_id: job_id)
    match.update!(
      fit_score: result[:overall_score],
      score_breakdown: result[:breakdown],
      explanation: result[:explanation],
      scored_at: Time.current
    )

    Rails.logger.info("[FitScoreWorker] Scored user=#{user_id} job=#{job_id} score=#{result[:overall_score]}")
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("[FitScoreWorker] Record not found: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("[FitScoreWorker] Error scoring user=#{user_id} job=#{job_id}: #{e.message}")
    raise # Let Sidekiq retry
  end
end
