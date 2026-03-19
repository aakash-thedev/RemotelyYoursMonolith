# frozen_string_literal: true

class JobSerializer < Blueprinter::Base
  identifier :id
  fields :external_id, :source, :title, :company_name, :company_logo_url,
         :location, :job_type, :category, :description, :required_skills,
         :salary_min, :salary_max, :salary_currency, :salary_display,
         :apply_url, :posted_at, :is_active, :is_verified
end
