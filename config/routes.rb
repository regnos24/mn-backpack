Mnbackpack::Engine.routes.draw do
  resources :artists do
    collection do
      get 'search'
      post 'search'
    end
    member do
      get 'albums'
      post 'albums'
      get 'tracks'
      post 'tracks'
    end
  end
  resources :albums do
    collection do
      get 'search'
      post 'search'
    end
  end
  resources :tracks do
    collection do
      get 'search'
      post 'search'
    end
  end
  root :to => 'index#index'
  match "/" => "index#index"
end
