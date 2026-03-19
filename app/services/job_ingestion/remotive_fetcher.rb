# frozen_string_literal: true

module JobIngestion
  class RemotiveFetcher
    API_URL = "https://remotive.com/api/remote-jobs"

    def initialize(category: "software-dev", limit: 100)
      @category = category
      @limit = limit
    end

    def call
      response = connection.get do |req|
        req.params["category"] = @category
        req.params["limit"] = @limit
      end

      unless response.success?
        Rails.logger.error("[RemotiveFetcher] API returned #{response.status}: #{response.body}")
        return []
      end

      data = JSON.parse(response.body)
      jobs = data["jobs"] || []

      jobs.map { |raw| normalize(raw) }
    rescue Faraday::Error => e
      Rails.logger.error("[RemotiveFetcher] Request failed: #{e.message}")
      []
    rescue JSON::ParserError => e
      Rails.logger.error("[RemotiveFetcher] JSON parse error: #{e.message}")
      []
    end

    private

    def connection
      @connection ||= Faraday.new(url: API_URL) do |f|
        f.request :json
        f.response :raise_error
        f.adapter Faraday.default_adapter
        f.options.timeout = 15
        f.options.open_timeout = 5
      end
    end

    def normalize(raw)
      {
        external_id: "remotive_#{raw['id']}",
        source: "remotive",
        title: raw["title"],
        company_name: raw["company_name"],
        company_logo: raw["company_logo"],
        category: raw["category"],
        description: raw["description"],
        url: raw["url"],
        location: raw["candidate_required_location"],
        job_type: raw["job_type"],
        salary: raw["salary"],
        posted_at: raw["publication_date"],
        tags: raw["tags"]
      }
    end
  end
end
