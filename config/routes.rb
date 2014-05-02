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
      post 'comments' => 'comments#create'
      get 'comments' => 'comments#index'
      # put 'comments/:comment_id' => 'comments#update'
      delete 'comments/:comment_id' => 'comments#destroy'
    end
  end

  concern :followable do
    member do
      post 'follow' => 'follows#create'
      get 'followers' => 'follows#followers'
      delete 'follow' => 'follows#destroy'
    end
  end

  concern :likeable do
    member do
      post 'like' => 'likes#create'
      get 'likers' => 'likes#likers'
      delete 'like' => 'likes#destroy'
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

  get 'cuisines' => 'keywords#cuisines'
  get 'specialties' => 'keywords#specialties'

  get 'keywords/:id/users' => 'keywords#users'
  match 'cuisines/:id/users', to: 'keywords#users', via: :get
  match 'specialties/:id/users', to: 'keywords#users', via: :get

  resources :users, only: [:update], concerns: [:followable, :taggable] do
    collection do
      post 'authentications' => 'authentications#create'
      get 'authentications' => 'authentications#index'
      get 'checkauthentication' => 'authentications#check'
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
      get 'followables' => 'users#followables'
      get 'likeables' => 'users#likeables'
    end
  end

  resources :items, only: [:create, :show, :update, :destroy], concerns: [:commentable, :likeable]

  resources :morsels, only: [:create, :show, :update, :destroy] do
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
