# frozen_string_literal: true

module Api
  module V1
    class FitScoresController < ApplicationController
      # GET /api/v1/jobs/:job_id/fit_score
      def show
        job = Job.find(params[:id])
        match = current_user.job_matches.find_by(job: job)

        if match
          render json: {
            job_id: job.id,
            fit_score: match.fit_score,
            score_breakdown: match.score_breakdown,
            explanation: match.explanation,
            scored_at: match.scored_at
          }, status: :ok
        else
          render json: { error: "No fit score calculated for this job yet" }, status: :not_found
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Job not found" }, status: :not_found
      end

      # POST /api/v1/fit-scores/refresh
      def refresh
        profile = current_user.profile

        unless profile
          render json: { error: "Please complete your profile first" }, status: :unprocessable_entity
          return
        end

        job_ids = params[:job_ids] || Job.active.recent.limit(50).pluck(:id)

        job_ids.each do |job_id|
          FitScoreWorker.perform_async(current_user.id, job_id)
        end

        render json: {
          message: "Fit score refresh queued",
          jobs_queued: job_ids.size
        }, status: :accepted
      end
    end
  end
end
