require 'sidekiq/web'

MorselApp::Application.routes.draw do
  root to: 'status#show'
  get 'status' => 'status#show'
  get 'configuration' => 'configuration#show'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  ActiveAdmin.routes(self)

  devise_for  :users,
              controllers: {
                sessions: 'sessions',
                registrations: 'registrations'
              }

  resources :users, only: [:index, :update] do
    collection do
      post 'authorizations' => 'authorizations#create'
      get 'checkusername(/:username)' => 'users#checkusername'
      post 'reserveusername(/:username)' => 'users#reserveusername'
      put ':user_id/updateindustry' => 'users#updateindustry'
      get 'me' => 'users#me'
      post 'unsubscribe' => 'users#unsubscribe'
      get 'activities' => 'activities#index'
      get 'notifications' => 'notifications#index'

      get ':user_id_or_username' => 'users#show'
      get ':user_id_or_username/posts' => 'posts#index'
      get ':user_id_or_username/feed' => 'morsels#index'
    end
    resources :authorizations, only: [:index]
  end

  resources :morsels, only: [:create, :show, :update, :destroy] do
    resources :comments, only: [:create, :index]
  end
  get 'feed' => 'morsels#index'
  post 'morsels/:morsel_id/like' => 'likes#create'
  delete 'morsels/:morsel_id/like' => 'likes#destroy'

  resources :comments, only: [:destroy]

  resources :posts, only: [:create, :index, :show, :update, :destroy] do
    collection do
      get 'drafts' => 'posts#drafts'
    end
    resources :morsels, only: [:update, :destroy]
  end
end
