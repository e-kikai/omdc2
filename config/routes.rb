Rails.application.routes.draw do
  namespace :system do
    get 'displays/index'
  end

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
  get "qrcode" => "main#qrcode"

  # resources :products, except: [:new, :create, :edit, :update, :destroy]

  # get  "search(/x/:xl_genre_id_eq)(/l/:large_genre_id_eq)(/ar/:area_eq)" => "products#index", as: :search
  get  "search"                      => "products#index", as: :search
  get  "xl_genre/:xl_genre_id"       => "products#index", as: :xl_genre
  get  "large_genre/:large_genre_id" => "products#index", as: :large_genre
  get  "genre/:genre_id"             => "products#index", as: :genre

  get  "detail/:id" => "products#show"
  get  "qr/:id"     => "products#qr"
  # get  "contact/:id"     => "products#contact"
  # post "contact/:id"     => "products#contact_do"
  # get  "contact_tel/:id" => "products#contact_tel"

  get  "search_by_list_no" => "products#search_by_list_no"
  # get  "search_by_ml"      => "products#search_by_ml"

  resources :wishlist, only: [:index, :create, :destroy]

  namespace :system do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    resources :opens do
      member do
        get "detail/:product_id" => :result_detail
      end
    end
    resources :companies, except: [:show, :delete]
    resources :areas,     except: [:show]
    resources :infos,     only: [:index, :edit, :update]
    resources :displays,  only: [:index, :edit, :update]

    resources :products, except: [:show] do
      collection do
        get   :images
        get   :csv
        post  "csv" => :csv_upload
        patch "csv" => :csv_import
      end

      member do
        post   :image_upload
        delete ":product_image_id" => :image_destroy
        patch  :images_order
      end
    end

    resources :bids, except: [:show, :edit, :update] do
      collection do
        get :results
        get :rakusatsu_sum
        get :shuppin_sum
        get :total
        get :total_list
      end
    end

    resources :list, only: [:index, :new, :edit, :update] do
      collection do
        get :hangtag
        get :ef
        get :carry_out
        get :qr
      end
    end

  end

  namespace :bid do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    get   'rule' => 'main#rule'
    patch 'rule' => 'main#rule_update'

    resources :products, except: [:show] do
      collection do
        get   :ml_get_genre
        get   :images
        get   :csv
        post  "csv" => :csv_upload
        patch "csv" => :csv_import
      end

      member do
        post   :image_upload
        delete ":product_image_id" => :image_destroy
        patch  :images_order
      end
    end

    resources :bids, except: [:show, :edit, :update] do
      collection do
        get :results
        get :rakusatsu_sum
        get :shuppin_sum
        get :total
      end
    end

    resources :opens, only: [:index, :show]
  end
end