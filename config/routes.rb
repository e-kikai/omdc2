Rails.application.routes.draw do
  namespace :system do
    get 'displays/index'
  end

  devise_for :systems,
    path:       'system',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]

  devise_for :companies,
    path:       'bid',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]

  root to: "main#index"

  get "mltest" => "main#get_ml_genre"
  get "qrcode" => "main#qrcode"

  get  "search"                      => "products#index", as: :search
  get  "xl_genre/:xl_genre_id"       => "products#index", as: :xl_genre
  get  "large_genre/:large_genre_id" => "products#index", as: :large_genre
  get  "genre/:genre_id"             => "products#index", as: :genre

  get  "detail/:id" => "products#show"
  get  "images/:id" => "products#images"

  get  "qr"         => "products#qr"
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
        # get :results
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
        get   :sim
      end

      member do
        post   :image_upload
        delete ":product_image_id" => :image_destroy
        patch  :images_order
      end
    end

    resources :bids, except: [:show, :edit, :update] do
      collection do
        # get :results
        get :rakusatsu_sum
        get :shuppin_sum
        get :total
        get :motobiki
      end
    end

    resources :opens, only: [:index, :show]
  end

  get '*path' => 'application#routing_error'
end
