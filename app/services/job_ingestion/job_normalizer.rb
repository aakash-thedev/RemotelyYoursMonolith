# frozen_string_literal: true

module JobIngestion
  class JobNormalizer
    def initialize(raw_jobs)
      @raw_jobs = raw_jobs
    end

    # Deduplicates by external_id and upserts into the Job table.
    # Returns an array of persisted Job records.
    def call
      deduplicated = deduplicate(@raw_jobs)
      persisted = []

      deduplicated.each do |attrs|
        job = Job.find_or_initialize_by(
          external_id: attrs[:external_id],
          source: attrs[:source]
        )

        job.assign_attributes(
          title: attrs[:title],
          company_name: attrs[:company_name],
          company_logo_url: attrs[:company_logo],
          category: attrs[:category],
          description: sanitize_html(attrs[:description]),
          apply_url: attrs[:url],
          location: attrs[:location],
          job_type: attrs[:job_type],
          salary_display: attrs[:salary],
          required_skills: attrs[:tags] || [],
          posted_at: parse_date(attrs[:posted_at]),
          is_active: true
        )

        if job.save
          persisted << job
        else
          Rails.logger.warn("[JobNormalizer] Failed to save job #{attrs[:external_id]}: #{job.errors.full_messages.join(', ')}")
        end
      end

      Rails.logger.info("[JobNormalizer] Persisted #{persisted.size} jobs from #{@raw_jobs.size} raw entries")
      persisted
    end

    private

    def deduplicate(jobs)
      jobs.uniq { |j| j[:external_id] }
    end

    def sanitize_html(text)
      return nil unless text.present?
      ActionController::Base.helpers.strip_tags(text).squish
    end

    def parse_date(value)
      return nil unless value.present?
      Time.zone.parse(value.to_s)
    rescue ArgumentError
      nil
    end
  end
end
