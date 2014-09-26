require 'sidekiq/web'

MorselApp::Application.routes.draw do
  root to: 'status#show'
  get 'status' => 'status#show'
  get 'configuration' => 'configuration#show'
  get 'proxy' => 'configuration#proxy'

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
      post 'comments' => 'comments#create'
      get 'comments' => 'comments#index'
      # put 'comments/:comment_id' => 'comments#update'
      delete 'comments/:comment_id' => 'comments#destroy'
    end
  end

  concern :followable do
    member do
      post 'follow' => 'follows#create'
      delete 'follow' => 'follows#destroy'
      get 'followers' => 'follows#followers'
    end
  end

  concern :likeable do
    member do
      post 'like' => 'likes#create'
      get 'likers' => 'likes#likers'
      delete 'like' => 'likes#destroy'
    end
  end

  concern :reportable do
    member do
      post 'report' => 'reports#create'
    end
  end

  concern :taggable do
    member do
      post 'tags' => 'tags#create'
      get 'cuisines' => 'tags#cuisines'
      get 'specialties' => 'tags#specialties'
      delete 'tags/:tag_id' => 'tags#destroy'
    end
  end

  resources :authentications, only: [:create, :index, :update, :destroy] do
    collection do
      get 'check' => 'authentications#check'
      get 'connections(/provider)' => 'authentications#connections' # DEPRECATED
      post 'connections(/provider)' => 'authentications#connections'
    end
  end

  get 'cuisines' => 'keywords#cuisines'
  get 'specialties' => 'keywords#specialties'

  resources :keywords, only: [], concerns: [:followable] do
    member do
      get 'users' => 'keywords#users'
    end
  end
  match 'cuisines/:id/users', to: 'keywords#users', via: :get
  match 'specialties/:id/users', to: 'keywords#users', via: :get

  resources :notifications, only: [:index] do
    collection do
      put 'mark_read'
      get 'unread_count'
    end

    member do
      put 'mark_read'
    end
  end

  resources :users, only: [:update], concerns: [:followable, :reportable, :taggable] do
    collection do
      get 'validate_email(/:email)' => 'users#validate_email'
      get 'validate_username(/:username)' => 'users#validate_username'
      get 'validateusername(/:username)' => 'users#validate_username'
      post 'reserveusername(/:username)' => 'users#reserveusername'
      post 'forgot_password' => 'users#forgot_password'
      post 'reset_password' => 'users#reset_password'
      get 'me' => 'users#me'
      post 'unsubscribe' => 'users#unsubscribe'
      get 'activities' => 'activities#index'
      get 'followables_activities' => 'activities#followables_activities'
      get 'notifications' => 'notifications#index'
      get 'search' => 'users#search'

      # Note: Keep these at the end
      get ':id' => 'users#show', id: /\d+/
      get ':username' => 'users#show', username: /[a-zA-Z]([A-Za-z0-9_]*)/
      get ':user_id/morsels' => 'morsels#index', user_id: /\d+/
      get ':username/morsels' => 'morsels#index', username: /[a-zA-Z]([A-Za-z0-9_]*)/
    end

    member do
      put 'updateindustry' => 'users#updateindustry'
      get 'followables' => 'users#followables'
      get 'likeables' => 'users#likeables'
      get 'places' => 'users#places'
    end
  end

  resources :items, only: [:create, :show, :update, :destroy], concerns: [:commentable, :likeable, :reportable]

  resources :morsels, only: [:create, :index, :show, :update, :destroy], concerns: [:reportable] do
    collection do
      get 'drafts' => 'morsels#drafts'
    end

    resources :items, only: [:update, :destroy]

    member do
      post 'publish' => 'morsels#publish'
      get 'tagged_users' => 'morsel_user_tags#users'
      post 'tagged_users/:user_id' => 'morsel_user_tags#create'
      delete 'tagged_users/:user_id' => 'morsel_user_tags#destroy'
    end
  end

  resources :places, only: [:show], concerns: [:followable, :reportable] do
    collection do
      get 'suggest' => 'places#suggest'
      get ':place_id/morsels' => 'morsels#index', place_id: /\d+/
      post ':place_id/employment' => 'employments#create', place_id: /\d+/
      post ':foursquare_venue_id/employment' => 'employments#create', foursquare_venue_id: /[A-Za-z0-9]+/
      delete ':place_id/employment' => 'employments#destroy'

      # HACK: Deprecated method
      post 'join' => 'employments#create'
    end

    member do
      get 'users' => 'places#users'
    end
  end

  get 'feed' => 'feed#index'
  get 'feed_all' => 'feed#all'

  post 'contact' => 'contact#create'

  match '*a', to: 'errors#routing', via: :all
end
