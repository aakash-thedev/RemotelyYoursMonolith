# frozen_string_literal: true

# Rate limiting with Rack::Attack
# Protects against brute-force login attempts and API abuse

class Rack::Attack
  ### Throttle login attempts by IP ###
  throttle("auth/ip", limit: 10, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1/auth/login") && req.post?
      req.ip
    end
  end

  ### Throttle signup by IP ###
  throttle("signup/ip", limit: 5, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1/auth/signup") && req.post?
      req.ip
    end
  end

  ### Throttle login attempts by email ###
  throttle("auth/email", limit: 5, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1/auth/login") && req.post?
      # Normalize email to prevent bypass
      req.params["email"].to_s.downcase.strip.presence
    end
  end

  ### General API rate limit per IP ###
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  ### Throttle fit score refresh (expensive operation) ###
  throttle("fit-scores/refresh", limit: 3, period: 60.seconds) do |req|
    if req.path.start_with?("/api/v1/fit-scores/refresh") && req.post?
      req.ip
    end
  end

  ### Throttle profile brief generation (expensive AI call) ###
  throttle("profile/generate_brief", limit: 5, period: 5.minutes) do |req|
    if req.path.include?("generate_brief") && req.post?
      req.ip
    end
  end

  ### Custom response for throttled requests ###
  self.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    retry_after = match_data[:period] - (now % match_data[:period])

    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ error: "Rate limit exceeded. Please retry in #{retry_after} seconds." }.to_json]
    ]
  end
end
