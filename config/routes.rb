Rails.application.routes.draw do
  get 'planning_pages/index'
  devise_for :users, controllers: {
    sessions: :sessions,
    registrations: :registrations
  }

  root controller: :planning_pages, action: :index
  resources :planning_pages, only: [:index]
end
