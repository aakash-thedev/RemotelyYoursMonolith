# frozen_string_literal: true

module Api
  module V1
    class ProfilesController < ApplicationController
      # GET /api/v1/profile
      def show
        profile = current_user.profile

        if profile
          render json: profile_response(profile), status: :ok
        else
          render json: { error: "Profile not found. Please create one." }, status: :not_found
        end
      end

      # PATCH /api/v1/profile
      def update
        profile = current_user.profile || current_user.build_profile

        if profile.update(profile_params)
          render json: {
            message: "Profile updated successfully",
            profile: profile_response(profile)
          }, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/profile/generate_brief
      def generate_brief
        profile = current_user.profile

        unless profile
          render json: { error: "Profile not found" }, status: :not_found
          return
        end

        brief = Ai::ProfileAnalyser.new(profile).call

        if brief.present?
          profile.update!(talent_brief: brief)
          render json: {
            message: "Talent brief generated",
            talent_brief: brief,
            profile: profile_response(profile)
          }, status: :ok
        else
          render json: { error: "Failed to generate talent brief" }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.permit(
          :headline, :bio, :location, :years_of_experience,
          :resume_url, :linkedin_url, :github_url, :portfolio_url,
          :desired_role, :desired_salary_min, :desired_salary_max,
          :remote_preference, :talent_brief, :timezone,
          :available_from, :onboarding_completed, :photo_url,
          skills: [], preferred_roles: []
        )
      end

      def profile_response(profile)
        {
          id: profile.id,
          user_id: profile.user_id,
          headline: profile.headline,
          bio: profile.bio,
          location: profile.location,
          skills: profile.skills,
          preferred_roles: profile.preferred_roles,
          years_of_experience: profile.years_of_experience,
          desired_role: profile.desired_role,
          desired_salary_min: profile.desired_salary_min,
          desired_salary_max: profile.desired_salary_max,
          remote_preference: profile.remote_preference,
          timezone: profile.timezone,
          available_from: profile.available_from,
          resume_url: profile.resume_url,
          linkedin_url: profile.linkedin_url,
          github_url: profile.github_url,
          portfolio_url: profile.portfolio_url,
          photo_url: profile.photo_url,
          talent_brief: profile.talent_brief,
          onboarding_completed: profile.onboarding_completed,
          updated_at: profile.updated_at
        }
      end
    end
  end
end
