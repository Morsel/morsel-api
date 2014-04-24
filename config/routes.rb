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

  concern :commentable do
    member do
      post 'comments' => 'items#comment'
      delete 'comments/:comment_id' => 'items#uncomment'
      get 'comments' => 'items#comments'
    end
  end

  concern :likeable do
    member do
      post 'like' => 'items#like'
      delete 'like' => 'items#unlike'
      get 'likers' => 'items#likers'
    end
  end

  resources :cuisines, only: [:index] do
    member do
      get 'users' => 'cuisines#users', id: /\d+/
    end
  end

  resources :users, only: [:update] do
    collection do
      post 'authorizations' => 'authorizations#create'
      get 'authorizations' => 'authorizations#index'
      get 'checkusername(/:username)' => 'users#checkusername' # DEPRECATED
      get 'validateusername(/:username)' => 'users#validateusername'
      post 'reserveusername(/:username)' => 'users#reserveusername'
      get 'me' => 'users#me'
      post 'unsubscribe' => 'users#unsubscribe'
      get 'activities' => 'activities#index'
      get 'notifications' => 'notifications#index'

      # Note: Keep these at the end
      get ':id' => 'users#show', id: /\d+/
      get ':username' => 'users#show', username: /[a-zA-Z][A-Za-z0-9_]+/
      get ':user_id/morsels' => 'morsels#index', user_id: /\d+/
      get ':username/morsels' => 'morsels#index', username: /[a-zA-Z][A-Za-z0-9_]+/
    end

    member do
      put 'updateindustry' => 'users#updateindustry'
    end

    get 'cuisines' => 'cuisines#index', user_id: /\d+/
  end

  resources :items, only: [:create, :show, :update, :destroy], concerns: [:commentable, :likeable]

  resources :morsels, only: [:create, :index, :show, :update, :destroy] do
    collection do
      get 'drafts' => 'morsels#drafts'
    end

    resources :items, only: [:update, :destroy]

    member do
      post 'publish' => 'morsels#publish'
    end
  end

  get 'feed' => 'feed#index'
end
