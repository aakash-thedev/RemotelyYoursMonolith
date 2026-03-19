# frozen_string_literal: true

class JobMatchSerializer < Blueprinter::Base
  identifier :id
  fields :fit_score, :score_breakdown, :explanation, :skills_matched, :skills_missing,
         :is_seen, :is_applied, :scored_at, :created_at

  association :job, blueprint: JobSerializer
end
