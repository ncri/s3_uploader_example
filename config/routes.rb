Html5S3Uploader::Application.routes.draw do

  root :to => 'uploads#index'

  resources :uploads
  #match '/uploads' => 'uploads#options', :constraints => {:method => 'OPTIONS'}

end
