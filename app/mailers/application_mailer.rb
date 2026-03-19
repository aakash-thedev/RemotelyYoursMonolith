# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@remotelyyours.com")
  layout false # API-only app, use inline templates
end
