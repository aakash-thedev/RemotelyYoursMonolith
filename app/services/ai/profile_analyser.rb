# frozen_string_literal: true

module Ai
  class ProfileAnalyser
    BRIEF_PROMPT = <<~PROMPT
      You are an expert tech talent analyst. Based on the following profile data, generate a concise
      "Talent Brief" — a 3-5 paragraph professional summary that highlights the candidate's strengths,
      ideal roles, and what makes them stand out.

      ## Profile
      - Name: %{name}
      - Headline: %{headline}
      - Bio: %{bio}
      - Skills: %{skills}
      - Experience: %{years_of_experience} years
      - Desired Role: %{desired_role}
      - Location: %{location}
      - Remote Preference: %{remote_preference}

      Write the brief in the third person. Be specific about technologies and strengths.
      Keep the tone professional but engaging.
    PROMPT

    def initialize(profile)
      @profile = profile
    end

    def call
      api_key = ENV["OPENAI_API_KEY"]

      unless api_key.present?
        Rails.logger.warn("[ProfileAnalyser] OPENAI_API_KEY not set — returning placeholder brief")
        return placeholder_brief
      end

      prompt = build_prompt
      response = call_openai(api_key, prompt)
      extract_content(response)
    rescue StandardError => e
      Rails.logger.error("[ProfileAnalyser] Error: #{e.message}")
      placeholder_brief
    end

    private

    def build_prompt
      format(
        BRIEF_PROMPT,
        name: @profile.user.full_name,
        headline: @profile.headline || "Not specified",
        bio: @profile.bio || "Not provided",
        skills: (@profile.skills_list.join(", ").presence || "Not specified"),
        years_of_experience: @profile.years_of_experience || "Unknown",
        desired_role: @profile.desired_role || "Not specified",
        location: @profile.location || "Not specified",
        remote_preference: @profile.remote_preference || "Not specified"
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
            { role: "system", content: "You are a professional tech talent analyst who writes compelling candidate briefs." },
            { role: "user", content: prompt }
          ],
          temperature: 0.7,
          max_tokens: 800
        }
      end

      response.body
    end

    def extract_content(response)
      content = response.dig("choices", 0, "message", "content")
      content.presence || placeholder_brief
    end

    def placeholder_brief
      user = @profile.user
      skills = @profile.skills_list.first(5).join(", ")
      "#{user.full_name} is a #{@profile.experience_level}-level professional with expertise in #{skills.presence || 'various technologies'}. " \
        "They are seeking #{@profile.desired_role || 'new opportunities'} in a #{@profile.remote_preference || 'flexible'} setting. " \
        "(This is a placeholder brief — configure OPENAI_API_KEY for AI-generated content.)"
    end
  end
end
