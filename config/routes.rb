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
        collection do
          get "my-matches", to: "jobs#my_matches"
        end
      end

      # fit scores
      post "fit-scores/refresh", to: "fit_scores#refresh"

      # subscription
      resource :subscription, only: %i[show] do
        post :create_order, on: :member
        post :verify_payment, on: :member
        delete :cancel, on: :member
      end
    end
  end
end
