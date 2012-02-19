Html5S3Uploader::Application.routes.draw do

  root :to => 'uploads#index'

  resources :uploads

end
