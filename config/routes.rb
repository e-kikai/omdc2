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

  namespace :system do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'

    resources :opens,     except: [:show]
    resources :companies, except: [:show]
  end

  namespace :bid do
    root to: "main#index"

    get    'edit_password' => 'main#edit_password'
    patch  'edit_password' => 'main#update_password'
  end
end
