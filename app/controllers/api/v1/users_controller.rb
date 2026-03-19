# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      # GET /api/v1/users/:id
      def show
        user = User.find(params[:id])

        render json: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          created_at: user.created_at,
          profile: user.profile&.as_json(except: %i[created_at updated_at])
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :not_found
      end
    end
  end
end
