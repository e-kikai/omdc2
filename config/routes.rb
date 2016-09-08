Rails.application.routes.draw do
  devise_for :systems,
    # controllers: { sessions: 'bamembers/sessions', },
    path:       'system',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]

  # root to: "bamember/main#index"

  devise_for :companies,
    path:       'member',
    path_names: {sign_in: 'login', sign_out: 'logout'},
    only:       [:sessions]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :system do
    root to: "main#index"
  end

  namespace :member do
    root to: "main#index"
  end
end
