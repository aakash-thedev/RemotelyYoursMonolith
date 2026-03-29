# frozen_string_literal: true

class JobIngestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default", retry: 3

  def perform
    Rails.logger.info("[JobIngestionWorker] Starting job ingestion...")

    # Fetch from all sources
    remotive_jobs = JobIngestion::RemotiveFetcher.new.call
    adzuna_jobs = JobIngestion::AdzunaFetcher.new.call
    himalayas_jobs = JobIngestion::HimalayasFetcher.new.call

    all_raw_jobs = remotive_jobs + adzuna_jobs + himalayas_jobs
    Rails.logger.info("[JobIngestionWorker] Fetched #{all_raw_jobs.size} raw jobs (Remotive: #{remotive_jobs.size}, Adzuna: #{adzuna_jobs.size}, Himalayas: #{himalayas_jobs.size})")

    # Normalize and persist
    persisted_jobs = JobIngestion::JobNormalizer.new(all_raw_jobs).call
    Rails.logger.info("[JobIngestionWorker] Persisted #{persisted_jobs.size} jobs")

    # Enqueue fit score calculations for all active users with profiles
    enqueue_fit_scores(persisted_jobs)

    # Deactivate stale jobs (older than 30 days)
    deactivate_stale_jobs

    Rails.logger.info("[JobIngestionWorker] Ingestion complete")
  end

  private

  def enqueue_fit_scores(jobs)
    user_ids = User.joins(:profile).where(profiles: { id: Profile.where.not(headline: nil) }).pluck(:id)

    count = 0
    user_ids.each do |user_id|
      jobs.each do |job|
        FitScoreWorker.perform_async(user_id, job.id)
        count += 1
      end
    end

    Rails.logger.info("[JobIngestionWorker] Enqueued #{count} fit score calculations")
  end

  def deactivate_stale_jobs
    stale = Job.where(is_active: true).where("posted_at < ?", 30.days.ago)
    count = stale.update_all(is_active: false)
    Rails.logger.info("[JobIngestionWorker] Deactivated #{count} stale jobs")
  end
end
