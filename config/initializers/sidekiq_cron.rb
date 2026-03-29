# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule = [
      {
        "name" => "job_ingestion",
        "cron" => "0 6 * * *",  # Every day at 6 AM UTC
        "class" => "JobIngestionWorker",
        "description" => "Daily job ingestion from Remotive and Adzuna"
      },
      {
        "name" => "weekly_digest",
        "cron" => "0 9 * * 1",  # Every Monday at 9 AM UTC
        "class" => "WeeklyDigestWorker",
        "description" => "Send weekly top-matches digest to Pro/Pro+ users"
      }
    ]

    schedule.each do |job|
      Sidekiq::Cron::Job.create(job)
    end
  end
end
