Rails.application.routes.draw do
  resources :hounds
  resources :conversations
  resources :fmauths
  root to: 'visitors#index'
  post "conversations/update"
end
