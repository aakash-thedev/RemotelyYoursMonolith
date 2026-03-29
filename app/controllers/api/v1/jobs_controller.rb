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

      # GET /api/v1/jobs/saved
      def saved
        matches = current_user
          .job_matches
          .saved
          .includes(:job)
          .order(updated_at: :desc)

        render json: {
          matches: matches.map { |m| match_response(m) },
          meta: { total: matches.size }
        }, status: :ok
      end

      # POST /api/v1/jobs/:id/save
      def save_job
        match = current_user.job_matches.find_by(job_id: params[:id])

        unless match
          render json: { error: "No match found for this job" }, status: :not_found
          return
        end

        match.update!(is_saved: true)
        render json: { message: "Job saved", match: match_response(match) }, status: :ok
      end

      # DELETE /api/v1/jobs/:id/save
      def unsave_job
        match = current_user.job_matches.find_by(job_id: params[:id])

        unless match
          render json: { error: "No match found for this job" }, status: :not_found
          return
        end

        match.update!(is_saved: false)
        render json: { message: "Job unsaved", match: match_response(match) }, status: :ok
      end

      # POST /api/v1/jobs/:id/apply
      def mark_applied
        match = current_user.job_matches.find_by(job_id: params[:id])

        unless match
          render json: { error: "No match found for this job" }, status: :not_found
          return
        end

        match.update!(is_applied: true)
        render json: { message: "Marked as applied", match: match_response(match) }, status: :ok
      end

      # GET /api/v1/jobs/preview
      def preview
        profile = current_user.profile

        unless profile
          render json: { error: "Profile not found. Complete onboarding first." }, status: :not_found
          return
        end

        user_skills = profile.skills_list.map(&:downcase)
        region = profile.job_region

        # Fetch active recent jobs filtered by region
        jobs = Job.active.recent.by_region(region).order(posted_at: :desc)

        # Score and sort by skills overlap
        scored_jobs = jobs.map do |job|
          job_skills = (job.required_skills || []).map(&:downcase)
          overlap = (user_skills & job_skills).size
          total = [user_skills.size, 1].max
          overlap_pct = overlap.to_f / total

          fit_hint = if overlap_pct >= 0.6
                       "High Match"
                     elsif overlap_pct >= 0.3
                       "Good Match"
                     else
                       "Fair Match"
                     end

          { job: job, overlap: overlap, fit_hint: fit_hint }
        end

        scored_jobs.sort_by! { |s| -s[:overlap] }
        total_matches = scored_jobs.size

        preview_jobs = scored_jobs.first(3).map do |s|
          job = s[:job]
          {
            id: job.id,
            title: job.title,
            company_name: job.company_name,
            location: job.location,
            skills: job.required_skills,
            salary_range: job.salary_range,
            category: job.category,
            posted_at: job.posted_at,
            fit_hint: s[:fit_hint]
          }
        end

        render json: {
          total_matches: total_matches,
          preview_jobs: preview_jobs,
          locked_count: [total_matches - 3, 0].max
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
          is_saved: match.is_saved,
          is_applied: match.is_applied,
          scored_at: match.scored_at
        }
      end
    end
  end
end
