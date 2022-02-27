Rails.application.routes.draw do
  post :login, to: 'access_tokens#create'
  delete :logout, to: 'access_tokens#destroy'
  post :signup, to: 'registrations#create'
  resources :articles do
    resources :comments, only: %i[index create]
  end
end
