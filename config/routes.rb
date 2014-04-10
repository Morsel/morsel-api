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

  resources :users, only: [:update] do
    collection do
      post 'authorizations' => 'authorizations#create'
      get 'authorizations' => 'authorizations#index'
      get 'checkusername(/:username)' => 'users#checkusername'
      post 'reserveusername(/:username)' => 'users#reserveusername'
      put ':id/updateindustry' => 'users#updateindustry'
      get 'me' => 'users#me'
      post 'unsubscribe' => 'users#unsubscribe'
      get 'activities' => 'activities#index'
      get 'notifications' => 'notifications#index'

      get ':user_id_or_username' => 'users#show'
      get ':user_id_or_username/morsels' => 'morsels#index'
    end
  end

  resources :items, only: [:create, :show, :update, :destroy] do
    resources :comments, only: [:create, :index]
    post 'like' => 'likes#create'
    delete 'like' => 'likes#destroy'
    get 'likers' => 'items#likers'
  end

  resources :comments, only: [:destroy]

  resources :morsels, only: [:create, :index, :show, :update, :destroy] do
    collection do
      get 'drafts' => 'morsels#drafts'
    end
    resources :items, only: [:update, :destroy]
    post 'publish' => 'morsels#publish'
  end

  get 'feed' => 'feed#index'
end
