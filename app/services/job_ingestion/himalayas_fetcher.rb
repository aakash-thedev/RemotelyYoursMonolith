# frozen_string_literal: true

module JobIngestion
  class HimalayasFetcher
    API_URL = "https://himalayas.app/jobs/api"

    def initialize(limit: 50)
      @limit = limit
    end

    def call
      response = connection.get do |req|
        req.params["limit"] = @limit
      end

      unless response.success?
        Rails.logger.error("[HimalayasFetcher] API returned #{response.status}: #{response.body}")
        return []
      end

      data = JSON.parse(response.body)
      jobs = data["jobs"] || []

      jobs.map { |raw| normalize(raw) }
    rescue Faraday::Error => e
      Rails.logger.error("[HimalayasFetcher] Request failed: #{e.message}")
      []
    rescue JSON::ParserError => e
      Rails.logger.error("[HimalayasFetcher] JSON parse error: #{e.message}")
      []
    end

    private

    def connection
      @connection ||= Faraday.new(url: API_URL) do |f|
        f.request :json
        f.adapter Faraday.default_adapter
        f.options.timeout = 15
        f.options.open_timeout = 5
      end
    end

    def normalize(raw)
      {
        external_id: "himalayas_#{raw['id']}",
        source: "himalayas",
        title: raw["title"],
        company_name: raw.dig("companyName") || raw.dig("company", "name"),
        company_logo: raw.dig("companyLogo") || raw.dig("company", "logo"),
        category: (raw["categories"] || []).first,
        description: raw["description"],
        url: raw["applicationLink"] || raw["url"],
        location: raw["location"] || "Remote",
        job_type: raw["type"],
        salary: format_salary(raw),
        posted_at: raw["pubDate"] || raw["publishedAt"],
        tags: raw["tags"] || raw["skills"] || []
      }
    end

    def format_salary(raw)
      min = raw["salaryCurrencyMin"] || raw["salaryMin"]
      max = raw["salaryCurrencyMax"] || raw["salaryMax"]
      return nil unless min || max
      "#{min&.to_i || '?'}–#{max&.to_i || '?'}"
    end
  end
end
