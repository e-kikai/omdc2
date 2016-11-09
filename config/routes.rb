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

  get "mltest" => "main#get_ml_genre"

  # resources :products, except: [:new, :create, :edit, :update, :destroy]

  # get  "search(/x/:xl_genre_id_eq)(/l/:large_genre_id_eq)(/ar/:area_eq)" => "products#index", as: :search
  get  "search"                      => "products#index", as: :search
  get  "xl_genre/:xl_genre_id"       => "products#index", as: :xl_genre
  get  "large_genre/:large_genre_id" => "products#index", as: :large_genre
  get  "genre/:genre_id"             => "products#index", as: :genre

  get  "detail/:id"      => "products#show"
  get  "contact/:id"     => "products#contact"
  post "contact/:id"     => "products#contact_do"
  get  "contact_tel/:id" => "products#contact_tel"

  get  "search_by_list_no" => "products#search_by_list_no"
  get  "search_by_ml"      => "products#search_by_ml"

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

    resources :products, except: [:show] do
      collection do
        get "ml_get_genre"
        get "imgs"
        get "pdf_test"
      end
    end
    # get       'product/ml_get_genre' => 'products#ml_get_genre'

    resources :bids, except: [:show, :edit, :update]
    get        'bids/results' => 'bids#results'
  end
end
