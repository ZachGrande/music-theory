Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  # Dashboard
  get "dashboard", to: "dashboard#show"

  # Quizzes
  resources :quizzes, only: %i[index show] do
    resources :quiz_attempts, only: %i[create show], path: "attempts" do
      member do
        post :submit
      end
    end
  end

  # User's quiz history
  resources :quiz_attempts, only: %i[index show], path: "my-quizzes"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#show"
end
