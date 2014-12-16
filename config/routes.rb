require 'sidekiq/web'

MorselApp::Application.routes.draw do
  root to: 'status#show'
  get 'status' => 'status#show'
  get 'configuration' => 'configuration#show'
  get '/proxy', to: redirect('/proxy.html')

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

  resources :authentications, only: [:create, :index, :show, :update, :destroy] do
    collection do
      get 'check' => 'authentications#check'
      get 'connections(/provider)' => 'authentications#connections' # DEPRECATED, Change: GET `/authentications/connections` - Authentication Connections -> POST `/authentications/connections` - Authentication Connections (https://app.asana.com/0/19486350215520/19486350215528)
      post 'connections(/provider)' => 'authentications#connections'
    end
  end

  get 'cuisines' => 'keywords#cuisines'
  get 'specialties' => 'keywords#specialties'

  resources :keywords, only: [], concerns: [:followable] do
    collection do
      get 'search' => 'keywords#search'
    end
    member do
      get 'users' => 'keywords#users'
    end
  end
  match 'cuisines/:id/users', to: 'keywords#users', via: :get
  match 'specialties/:id/users', to: 'keywords#users', via: :get
  match 'hashtags/:name/morsels', to: 'keywords#morsels_for_name', via: :get, name: /[A-Za-z0-9_]*/
  match 'hashtags/search', to: 'keywords#search', via: :get

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
      get 'validateusername(/:username)' => 'users#validate_username' # DEPRECATED, Change: GET `/users/validateusername` - Validate Username -> [GET `/users/validate_username` - Validate Username (https://app.asana.com/0/19486350215520/19486350215530)
      post 'reserveusername(/:username)' => 'users#reserveusername'
      post 'forgot_password' => 'users#forgot_password'
      post 'reset_password' => 'users#reset_password'
      get 'me' => 'users#me'
      post 'unsubscribe' => 'users#unsubscribe'
      get 'activities' => 'activities#index'
      get 'devices' => 'devices#index'
      post 'devices' => 'devices#create'
      delete 'devices/:id' => 'devices#destroy'
      put 'devices/:id' => 'devices#update'
      get 'followables_activities' => 'activities#followables_activities'
      get 'notifications' => 'notifications#index'
      get 'search' => 'users#search'

      # Note: Keep these at the end
      get ':id' => 'users#show', id: /\d+/
      get ':username' => 'users#show', username: /[a-zA-Z]([A-Za-z0-9_]*)/
      get ':user_id/morsels' => 'morsels#index', user_id: /\d+/
      get ':username/morsels' => 'morsels#index', username: /[a-zA-Z]([A-Za-z0-9_]*)/
    end

    resources :collections, only: [:index]

    member do
      put 'updateindustry' => 'users#updateindustry'
      get 'followables' => 'users#followables'
      get 'likeables' => 'users#likeables'
      get 'places' => 'users#places'
    end
  end

  resources :collections, only: [:show, :create, :update, :destroy] do
    member do
      get 'morsels'
    end
  end

  # DEPRECATED, Remove: GET `/items/:id/likers` - Likers (https://app.asana.com/0/19486350215520/19486350215534). Items are no longer likeable
  # DEPRECATED, Remove: POST `/items/:id/like` - Like Item (https://app.asana.com/0/19486350215520/19486350215536). Items are no longer likeable
  # DEPRECATED, Remove: DELETE `/items/:id/like` - Unlike Item (https://app.asana.com/0/19486350215520/19486350215538). Items are no longer likeable
  resources :items, only: [:create, :show, :update, :destroy], concerns: [:commentable, :likeable, :reportable]

  resources :morsels, only: [:create, :index, :show, :update, :destroy], concerns: [:reportable, :likeable] do
    collection do
      get 'drafts' => 'morsels#drafts'
      get 'search' => 'morsels#search'
    end

    resources :items, only: [:update, :destroy]

    member do
      post 'publish' => 'morsels#publish'
      get 'tagged_users' => 'morsel_user_tags#users'
      get 'eligible_tagged_users' => 'morsel_user_tags#eligible_users'
      post 'tagged_users/:user_id' => 'morsel_user_tags#create'
      delete 'tagged_users/:user_id' => 'morsel_user_tags#destroy'
      post 'collect' => 'morsels#collect'
      delete 'collect' => 'morsels#uncollect'
    end
  end

  resources :places, only: [:show], concerns: [:followable, :reportable] do
    collection do
      get 'suggest' => 'places#suggest'
      get ':place_id/morsels' => 'morsels#index', place_id: /\d+/
      post ':place_id/employment' => 'employments#create', place_id: /\d+/
      post ':foursquare_venue_id/employment' => 'employments#create', foursquare_venue_id: /[A-Za-z0-9]+/
      delete ':place_id/employment' => 'employments#destroy'
    end

    resources :collections, only: [:index]

    member do
      get 'users' => 'places#users'
    end
  end

  get 'feed' => 'feed#index'
  get 'feed_all' => 'feed#all'

  post 'contact' => 'contact#create'

  match '*a', to: 'errors#routing', via: :all
end
