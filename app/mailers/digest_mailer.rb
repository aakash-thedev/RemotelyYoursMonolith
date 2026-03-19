# frozen_string_literal: true

class DigestMailer < ApplicationMailer
  def weekly_digest(user:, matches:)
    @user = user
    @matches = matches
    @frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3000")

    mail(
      to: @user.email,
      subject: "Your top #{@matches.size} job matches this week - RemotelyYours"
    )
  end
end
