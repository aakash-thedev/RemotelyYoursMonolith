# frozen_string_literal: true

namespace :jobs do
  desc "Run job ingestion from all sources (Remotive, Adzuna, Himalayas)"
  task ingest: :environment do
    puts "Starting job ingestion..."
    JobIngestionWorker.new.perform
    puts "Done! Total active jobs: #{Job.active.count}"
  end

  desc "Seed sample jobs for development"
  task seed: :environment do
    load Rails.root.join("db/seeds.rb")
  end
end
