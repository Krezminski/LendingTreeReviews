Rails.application.routes.draw do
  get '/reviews', to: 'reviews#index'
end
