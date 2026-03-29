Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Support comma-separated origins for multiple frontend domains
    allowed_origins = ENV.fetch("CORS_ORIGINS", ENV.fetch("FRONTEND_URL", "http://localhost:3000"))
                         .split(",")
                         .map(&:strip)

    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      credentials: true
  end
end
