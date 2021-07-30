# frozen_string_literal: true
Rails.application.routes.draw do
  mount Qa::Engine => '/qa'

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new

  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resources :hold_requests

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }, skip: "sessions"

  devise_scope :user do
    get 'sign_in', to: 'sessions#new', as: :new_user_session
    post 'sign_in', to: 'sessions#create', as: :user_session
    get 'sign_out', to: 'sessions#destroy', as: :destroy_user_session
    get 'shib/sign_in', to: 'omniauth#new', as: :new_user_shib_session
    post 'shib/sign_in', to: 'omniauth_callbacks#shibboleth', as: :new_session
    get "alma/social_login_callback", to: "sessions#social_login_callback"
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/alma_availability/:id', to: 'application#alma_availability'

  get "/contact", to: "static#contact"
  get "/about", to: "static#about"
  get "/help", to: "static#help"
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#unhandled_exception', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  get '/collections/search', to: 'collections#search'
end
