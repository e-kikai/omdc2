Rails.application.routes.draw do
  devise_for :systems,
    # controllers: { sessions: 'bamembers/sessions', },
    path:       'system',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]

  # root to: "bamember/main#index"

  devise_for :companies,
    path:       'bid',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "main#index"

  get 'search' => 'main#search'

  get "mltest" => "main#get_ml_genre"

  resources :products, except: [:new, :create, :edit, :update, :destroy]


  namespace :system do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    resources :opens,     except: [:show]
    resources :companies, except: [:show]
    resources :products,  except: [:show]
  end

  namespace :bid do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    resources :products, except: [:show]
    get       'product/ml_get_genre' => 'products#ml_get_genre'

    resources :bids, except: [:show, :edit, :update]
    get        'bids/results' => 'bids#results'
  end
end
