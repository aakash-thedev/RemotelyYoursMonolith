# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[signup login google]

      # POST /api/v1/auth/signup
      def signup
        user = User.new(signup_params)

        ActiveRecord::Base.transaction do
          if user.save
            user.create_profile!
            user.create_subscription!(plan: :free, status: :active, started_at: Time.current)

            token = encode_token(user)
            render json: {
              message: "Account created successfully",
              token: token,
              user: UserSerializer.render_as_hash(user)
            }, status: :created
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: login_params[:email]&.downcase&.strip)

        if user&.authenticate(login_params[:password])
          token = encode_token(user)
          render json: {
            message: "Logged in successfully",
            token: token,
            user: UserSerializer.render_as_hash(user)
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/google
      def google
        id_token = params[:id_token]

        unless id_token.present?
          render json: { error: "Google ID token is required" }, status: :bad_request
          return
        end

        google_payload = verify_google_token(id_token)

        unless google_payload
          render json: { error: "Invalid Google token" }, status: :unauthorized
          return
        end

        user = User.find_or_initialize_by(email: google_payload[:email])

        if user.new_record?
          user.assign_attributes(
            full_name: google_payload[:name],
            provider: "google",
            uid: google_payload[:sub],
            password: SecureRandom.hex(16)
          )
          ActiveRecord::Base.transaction do
            user.save!
            user.create_profile!
            user.create_subscription!(plan: :free, status: :active, started_at: Time.current)
          end
        end

        token = encode_token(user)
        render json: {
          message: "Authenticated with Google",
          token: token,
          user: UserSerializer.render_as_hash(user)
        }, status: :ok
      end

      # DELETE /api/v1/auth/logout
      def logout
        render json: { message: "Logged out successfully" }, status: :ok
      end

      private

      def signup_params
        params.permit(:full_name, :email, :password, :password_confirmation)
      end

      def login_params
        params.permit(:email, :password)
      end

      def verify_google_token(id_token)
        client_id = ENV["GOOGLE_CLIENT_ID"]
        unless client_id.present?
          Rails.logger.error("[Auth] GOOGLE_CLIENT_ID not configured")
          return nil
        end

        # Use Google's tokeninfo endpoint for verification (simple, no extra deps)
        conn = Faraday.new(url: "https://oauth2.googleapis.com")
        response = conn.get("/tokeninfo", { id_token: id_token })

        unless response.status == 200
          Rails.logger.warn("[Auth] Google token verification failed: #{response.status}")
          return nil
        end

        payload = JSON.parse(response.body)

        # Verify the token was issued for our app
        unless payload["aud"] == client_id
          Rails.logger.warn("[Auth] Google token audience mismatch: #{payload['aud']}")
          return nil
        end

        { email: payload["email"], name: payload["name"], sub: payload["sub"] }
      rescue StandardError => e
        Rails.logger.error("[Auth] Google token verification error: #{e.message}")
        nil
      end
    end
  end
end
