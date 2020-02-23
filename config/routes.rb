Rails.application.routes.draw do
  resources :speaks
  resources :hounds
  resources :conversations
  resources :fmauths
  root to: 'visitors#index'
  post "conversations/check"
end
