Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :login, only: [:new]
  post 'mock-sinai', to: 'login#mock_sinai'
end
