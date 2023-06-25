Rails.application.routes.draw do
  devise_for :systems,
    path:        'system',
    path_names:  {sign_in: 'login', sign_out: 'logout'},
    only:        [:sessions],
    controllers: { sessions: 'system/sessions' }

  devise_for :companies,
    path:        'bid',
    path_names:  {sign_in: 'login', sign_out: 'logout'},
    only:        [:sessions],
    controllers: { sessions: 'bid/sessions' }

  devise_for :users,
    path: :users,
    path_names: {sign_in: 'login', sign_out: 'logout'},
    controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations', sessions: 'users/sessions' }
  # if Rails.env.development?
  #   mount LetterOpenerWeb::Engine, at: "/letter_opener"
  # end

  root to: "main#index"
  get "mltest" => "main#get_ml_genre"
  get "qrcode" => "main#qrcode"
  get "search" => "main#search"


  # get  "search"                      => "products#index", as: :search
  get  "xl_genre/:xl_genre_id"       => "products#index", as: :xl_genre
  get  "large_genre/:large_genre_id" => "products#index", as: :large_genre
  get  "genre/:genre_id"             => "products#index", as: :genre
  get  "special/:special_key"        => "products#index", as: :special

  # get  "detail/:id"   => "products#show"
  get "detail/:id" => redirect("/products/%{id}")

  resources :products, only: [:index, :show] do
    collection do
      get  :list_no
      get  :image_vector_search_by_file
      post :image_vector_search_by_file
      get  :image
      get  :search_by_list_no
    end

    member do
      get :image_vector_search
      get :images
      get :youtube
    end
  end

  # get  "images/:id"   => "products#images"
  # get  "youtube/:id"  => "products#youtube"
  # get  "bid_list"     => "products#bid_list"
  # get  "search_by_list_no" => "products#search_by_list_no"

  get "images/:id"  => redirect("/products/%{id}/images")
  get "youtube/:id" => redirect("/products/%{id}/youtube")
  get "bid_list"    => redirect("/products/list_no")
  get "search_by_list_no" => "products#search_by_list_no"

  get  "ml_get_genre" => "products#ml_get_genre"

  get  "qr"         => "products#qr"
  # get  "contact/:id"     => "products#contact"
  # post "contact/:id"     => "products#contact_do"
  # get  "contact_tel/:id" => "products#contact_tel"

  # get  "search_by_ml"      => "products#search_by_ml"

  # resources :wishlist, only: [:index, :create, :destroy]

  resources :contacts, only: [:new, :create] do
    collection do
      get :fin
    end
  end

  resources :detail_logs,  only: [:create]
  resources :toppage_logs, only: [:create]
  resources :search_logs,  only: [:create]

  # resources :helps, only: [:show]
  resources :helps, only: [] do
    collection do
      get :beginner
      get :faq
    end
  end

  get "search" => "main#search"


  ### マイページ ###
  namespace :mypage do
    root to: "main#index"

    get   'edit_password' => 'main#edit_password'
    patch 'edit_password' => 'main#update_password'
    get   'edit_user'     => 'main#edit_user'
    patch 'edit_user'     => 'main#update_user'

    resources :products,  only: [:index]
    resources :favorites, only: [:index, :create, :destroy] do
      collection do
        post  "toggle"
        patch "request_list"
      end
    end
    resources :contacts,  only: [:new, :create]
  end

  namespace :system do
    root to: "main#index"

    get   'edit_password' => 'main#edit_password'
    patch 'edit_password' => 'main#update_password'

    resources :opens do
      member do
        get "detail/:product_id" => :result_detail
      end

      member do
        get   :products
        get   :detail_logs
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

    resources :bids, except: [:show] do
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

        get    "carryout"     => :carryout_new
        get    "carryout/:id" => :carryout_edit
        patch  "carryout/:id" => :carryout_update
        delete "carryout/:id" => :carryout_destroy

        get :ads
      end
    end

    resources :bt, only: [:index, :new, :edit, :update] do
      collection do
        get    "carryout"     => :carryout_new
        get    "carryout/:id" => :carryout_edit
        patch  "carryout/:id" => :carryout_update
        delete "carryout/:id" => :carryout_destroy
      end
    end

    resources :users,        only: [:index, :show, :destroy]
    resources :contacts,     only: [:index]
    resources :favorites,    only: [:index]
    resources :detail_logs,  only: [:index]
    resources :toppage_logs, only: [:index]
    resources :search_logs,  only: [:index]

    resources :scheduling, only: [:index] do
      collection do
        post 'vectors_process'
        get  'recommend_products_mail'
        get  'tracking/:r/:dummy' => :tracking
      end
    end

    resources :total,  only: [:index] do
      collection do
        # get 'goal'
        get 'opens'
        get 'formula'
      end
    end

    unless Rails.env.production?
      resources :playground, only: [:show] do
        collection do
          get 'search_01'
          get 'search_02'
          post 'search_02'
          get 'image'

          get 'kmeans_01'


          get 'vector_maker'
          get 'vector_maker_solo'

          get "mock_list_01"
          get "mock_list_02"

          get 'vector_search_json'
        end
      end
    end

    resources :mailchimp_html, only: [:index]
    resources :mailchimp_user_html, only: [:index]
  end

  namespace :bid do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    get   'rule' => 'main#rule'
    patch 'rule' => 'main#rule_update'

    resources :products, except: [:show] do
      collection do
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

    resources :bids, except: [:show] do
      collection do
        # get :results
        get :rakusatsu_sum
        get :shuppin_sum
        get :total
        get :motobiki
      end
    end

    resources :opens, only: [:index, :show]

    # resources :users, only: [:index, :new, :create, :edit, :update, :destroy] do
    #   collection do
    #     get   :csv
    #     post  "csv" => :csv_upload
    #     patch "csv" => :csv_import
    #   end
    # end
    #
    # resources :requests, only: [:index, :show, :update]
  end

  get '*path' => 'application#routing_error'
end
