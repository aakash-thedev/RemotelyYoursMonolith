# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_user!

  # Global exception handlers for production safety
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: "#{e.model || 'Record'} not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: "Missing parameter: #{e.param}" }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    token = cookies[:ry_token] if token.blank?

    if token.blank?
      render json: { error: "Authorization token missing" }, status: :unauthorized
      return
    end

    begin
      secret = ENV.fetch("JWT_SECRET") { raise "JWT_SECRET not configured" }
      decoded = JWT.decode(token, secret, true, algorithm: "HS256")
      payload = decoded.first
      @current_user = User.find(payload["user_id"])
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def encode_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: 30.days.from_now.to_i
    }
    JWT.encode(payload, ENV.fetch("JWT_SECRET"), "HS256")
  end

  def set_auth_cookie(token)
    cookies[:ry_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: 30.days.from_now,
      path: "/"
    }
  end

  def clear_auth_cookie
    cookies.delete(:ry_token, path: "/")
  end
end
