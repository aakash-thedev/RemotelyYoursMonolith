# frozen_string_literal: true

module JobIngestion
  class AdzunaFetcher
    BASE_URL = "https://api.adzuna.com/v1/api/jobs"

    def initialize(country: "us", category: "it-jobs", results_per_page: 50)
      @country = country
      @category = category
      @results_per_page = results_per_page
    end

    def call
      app_id = ENV["ADZUNA_APP_ID"]
      app_key = ENV["ADZUNA_APP_KEY"]

      unless app_id.present? && app_key.present?
        Rails.logger.warn("[AdzunaFetcher] Missing ADZUNA_APP_ID or ADZUNA_APP_KEY — skipping")
        return []
      end

      response = connection.get("/v1/api/jobs/#{@country}/search/1") do |req|
        req.params["app_id"] = app_id
        req.params["app_key"] = app_key
        req.params["results_per_page"] = @results_per_page
        req.params["what"] = "remote software developer"
        req.params["category"] = @category
        req.params["content-type"] = "application/json"
      end

      unless response.success?
        Rails.logger.error("[AdzunaFetcher] API returned #{response.status}: #{response.body}")
        return []
      end

      data = JSON.parse(response.body)
      results = data["results"] || []

      results.map { |raw| normalize(raw) }
    rescue Faraday::Error => e
      Rails.logger.error("[AdzunaFetcher] Request failed: #{e.message}")
      []
    rescue JSON::ParserError => e
      Rails.logger.error("[AdzunaFetcher] JSON parse error: #{e.message}")
      []
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.adapter Faraday.default_adapter
        f.options.timeout = 15
        f.options.open_timeout = 5
      end
    end

    def normalize(raw)
      {
        external_id: "adzuna_#{raw['id']}",
        source: "adzuna",
        title: raw["title"],
        company_name: raw.dig("company", "display_name"),
        company_logo: nil,
        category: raw.dig("category", "label"),
        description: raw["description"],
        url: raw["redirect_url"],
        location: raw.dig("location", "display_name"),
        job_type: raw["contract_type"],
        salary: format_salary(raw),
        posted_at: raw["created"],
        tags: []
      }
    end

    def format_salary(raw)
      min = raw["salary_min"]
      max = raw["salary_max"]
      return nil unless min || max
      "#{min&.to_i || '?'}–#{max&.to_i || '?'}"
    end
  end
end
