# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[index show]

      # GET /api/v1/jobs
      def index
        jobs = Job.active.recent.order(posted_at: :desc)

        # Optional filters
        if params[:q].present?
          sanitized_q = params[:q].to_s.gsub(/[%_\\]/) { |c| "\\#{c}" }
          jobs = jobs.where("title ILIKE ?", "%#{sanitized_q}%")
        end
        jobs = jobs.where(category: params[:category]) if params[:category].present?
        jobs = jobs.where("salary_min >= ?", params[:salary_min]) if params[:salary_min].present?

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
        total = jobs.count
        jobs = jobs.offset((page - 1) * per_page).limit(per_page)

        render json: {
          jobs: jobs.as_json(except: %i[created_at updated_at]),
          meta: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total.to_f / per_page).ceil
          }
        }, status: :ok
      end

      # GET /api/v1/jobs/:id
      def show
        job = Job.find(params[:id])
        render json: job.as_json(except: %i[created_at updated_at]), status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Job not found" }, status: :not_found
      end

      # GET /api/v1/jobs/my-matches
      def my_matches
        matches = current_user
          .job_matches
          .includes(:job)
          .where("fit_score >= ?", params.fetch(:min_score, 0).to_f)
          .order(fit_score: :desc)

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
        total = matches.count
        matches = matches.offset((page - 1) * per_page).limit(per_page)

        render json: {
          matches: matches.map { |m| match_response(m) },
          meta: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total.to_f / per_page).ceil
          }
        }, status: :ok
      end

      private

      def match_response(match)
        {
          id: match.id,
          job: match.job.as_json(except: %i[created_at updated_at]),
          fit_score: match.fit_score,
          score_breakdown: match.score_breakdown,
          explanation: match.explanation,
          scored_at: match.scored_at
        }
      end
    end
  end
end
