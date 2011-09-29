Mnbackpack::Engine.routes.draw do
  resources :search
  root :to => 'index#index'
  match "/" => "index#index"
end
