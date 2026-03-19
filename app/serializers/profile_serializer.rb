# frozen_string_literal: true

class ProfileSerializer < Blueprinter::Base
  identifier :id
  fields :user_id, :headline, :bio, :location, :years_of_experience, :skills, :preferred_roles,
         :desired_role, :desired_salary_min, :desired_salary_max, :remote_preference,
         :timezone, :available_from, :github_url, :linkedin_url,
         :portfolio_url, :resume_url, :photo_url, :talent_brief, :onboarding_completed, :updated_at
end
