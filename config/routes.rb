# frozen_string_literal: true
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resources :login, only: [:new]
  get '/login', to: 'login#new', as: 'login'
  get '/login_response', to: 'login#login_response'
  post 'mock-sinai', to: 'login#mock_sinai'
  root 'static#index'
  get '/cookie', to: 'static#cookie_test'
  resources 'darrow'
end
