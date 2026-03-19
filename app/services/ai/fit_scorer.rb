# frozen_string_literal: true

module Ai
  class FitScorer
    PROMPT_TEMPLATE = <<~PROMPT
      You are an expert tech recruiter AI. Evaluate how well this candidate matches the given job posting.

      ## Candidate Profile
      - Name: %{candidate_name}
      - Headline: %{headline}
      - Skills: %{skills}
      - Experience: %{years_of_experience} years
      - Desired Role: %{desired_role}
      - Desired Salary: %{salary_range}
      - Location Preference: %{remote_preference}
      - Bio: %{bio}

      ## Job Posting
      - Title: %{job_title}
      - Company: %{company_name}
      - Description: %{job_description}
      - Location: %{job_location}
      - Job Type: %{job_type}
      - Salary: %{job_salary}
      - Tags: %{job_tags}

      ## Instructions
      Score this candidate-job fit on the following dimensions (0-100 each):
      1. **skills_match** — How well do the candidate's skills match the job requirements?
      2. **experience_match** — Is the candidate's experience level appropriate?
      3. **role_fit** — Does the job title/role align with the candidate's desired role?
      4. **location_fit** — Does the job location/remote policy match the candidate's preference?

      Compute an **overall_score** as a weighted average:
        skills_match (40%%) + experience_match (25%%) + role_fit (20%%) + location_fit (15%%)

      Respond ONLY with valid JSON (no markdown fences):
      {
        "overall_score": <number>,
        "breakdown": {
          "skills_match": <number>,
          "experience_match": <number>,
          "role_fit": <number>,
          "location_fit": <number>
        },
        "explanation": "<2-3 sentence explanation of the score>"
      }
    PROMPT

    def initialize(profile, job)
      @profile = profile
      @job = job
    end

    def call
      api_key = ENV["OPENAI_API_KEY"]

      unless api_key.present?
        Rails.logger.warn("[FitScorer] OPENAI_API_KEY not set — returning random development score")
        return development_score
      end

      prompt = build_prompt
      response = call_openai(api_key, prompt)
      parse_response(response)
    rescue StandardError => e
      Rails.logger.error("[FitScorer] Error: #{e.message}")
      development_score
    end

    private

    def build_prompt
      format(
        PROMPT_TEMPLATE,
        candidate_name: @profile.user.full_name,
        headline: @profile.headline || "Not specified",
        skills: (@profile.skills_list.join(", ").presence || "Not specified"),
        years_of_experience: @profile.years_of_experience || "Unknown",
        desired_role: @profile.desired_role || "Not specified",
        salary_range: salary_range_string,
        remote_preference: @profile.remote_preference || "Not specified",
        bio: @profile.bio || "Not provided",
        job_title: @job.title,
        company_name: @job.company_name || "Unknown",
        job_description: truncate_text(@job.description, 1500),
        job_location: @job.location || "Not specified",
        job_type: @job.job_type || "Not specified",
        job_salary: @job.salary_display || "Not specified",
        job_tags: (@job.required_skills.is_a?(Array) ? @job.required_skills.join(", ") : @job.required_skills.to_s)
      )
    end

    def call_openai(api_key, prompt)
      conn = Faraday.new(url: "https://api.openai.com") do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
        f.options.timeout = 30
      end

      response = conn.post("/v1/chat/completions") do |req|
        req.headers["Authorization"] = "Bearer #{api_key}"
        req.body = {
          model: "gpt-4o-mini",
          messages: [
            { role: "system", content: "You are a precise JSON-outputting recruiter AI." },
            { role: "user", content: prompt }
          ],
          temperature: 0.3,
          max_tokens: 500
        }
      end

      response.body
    end

    def parse_response(response)
      content = response.dig("choices", 0, "message", "content")
      raise "Empty OpenAI response" unless content.present?

      parsed = JSON.parse(content)

      {
        overall_score: parsed["overall_score"].to_f.round(1),
        breakdown: parsed["breakdown"],
        explanation: parsed["explanation"]
      }
    rescue JSON::ParserError => e
      Rails.logger.error("[FitScorer] Failed to parse OpenAI response: #{e.message}")
      development_score
    end

    def development_score
      {
        overall_score: rand(45..92).to_f,
        breakdown: {
          skills_match: rand(40..95),
          experience_match: rand(40..95),
          role_fit: rand(40..95),
          location_fit: rand(50..100)
        },
        explanation: "Development placeholder score — OPENAI_API_KEY not configured."
      }
    end

    def salary_range_string
      min = @profile.desired_salary_min
      max = @profile.desired_salary_max
      return "Not specified" unless min || max
      "#{min || '?'}–#{max || '?'}"
    end

    def truncate_text(text, max_length)
      return "" unless text.present?
      text.length > max_length ? "#{text[0...max_length]}..." : text
    end
  end
end
