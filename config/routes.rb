# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # auth
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/google", to: "auth#google"
      delete "auth/logout", to: "auth#logout"

      # profile
      resource :profile, only: %i[show update] do
        post :generate_brief, on: :member
      end

      # jobs
      resources :jobs, only: %i[index show] do
        get :fit_score, on: :member, to: "fit_scores#show"
        post :save, on: :member, to: "jobs#save_job"
        delete :save, on: :member, to: "jobs#unsave_job"
        post :apply, on: :member, to: "jobs#mark_applied"
        collection do
          get "my-matches", to: "jobs#my_matches"
          get "saved", to: "jobs#saved"
          get "preview", to: "jobs#preview"
        end
      end

      # fit scores
      post "fit-scores/refresh", to: "fit_scores#refresh"

      # subscription
      resource :subscription, only: %i[show] do
        get :plans, on: :collection
        post :create_order, on: :member
        post :verify_payment, on: :member
        delete :cancel, on: :member
      end

      # password management
      post "auth/change_password", to: "auth#change_password"
      post "auth/forgot_password", to: "auth#forgot_password"
      post "auth/reset_password", to: "auth#reset_password"
    end
  end
end
