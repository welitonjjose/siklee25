Rails.application.routes.draw do
  # mount Rswag::Api::Engine => '/api-docs'
  # mount Rswag::Ui::Engine => '/api-docs'
  # mount ActionCable::server => '/cable'


  resources :employees, only: %i[new create], path: 'funcionarios'
  # resource :two_factor_settings, except: [:index, :show]

  # Auth
  devise_for :admin, controllers: {
    password_expired: 'funcionarios/password_expired',
    sessions: 'admin/sessions',
  }

  devise_for :empresas, controllers: {
    registrations: 'empresas/registrations',
    password_expired: 'funcionarios/password_expired',
    sessions: 'empresas/sessions',
  }

  devise_for :funcionarios, controllers: {
    omniauth_callbacks: 'funcionarios/omniauth_callbacks',
    registrations: 'funcionarios/registrations',
    sessions: 'funcionarios/sessions',
    password_expired: 'funcionarios/password_expired',
  }

  devise_for :consultants, controllers: {
    registrations: 'consultants/registrations',
    password_expired: 'funcionarios/password_expired',
    sessions: 'consultants/sessions',
  }

  devise_for :consultant_teams, controllers: {
    registrations: 'consultant_teams/registrations',
    password_expired: 'funcionarios/password_expired',
    sessions: 'consultant_teams/sessions',
  }

  # Pages
  get 'consultant', to: 'pages#consultant'
  get 'contact', to: 'pages#contact'
  root to: 'pages#home'
  get 'lgpd_text', to: 'pages#lgpd_text'

  resource :dashboard, only: :show

  # Resources
  resources :tutorials, path: 'tutoriais', only: :index

  resources :empresas_pages do
    collection do
      get :importar_funcionarios
      post :importar_funcionarios_create
    end
  end

  get 'empresas/:id/funcionarios', to: 'companies#employees', as: :company_employees

  get 'funcionarios_form/:id', to: 'empresas_pages#funcionarios_form', as: :funcionarios_form
  patch 'funcionarios_form/:id', to: 'empresas_pages#funcionarios_form_update', as: :funcionarios_form_update
  get 'funcionarios_function', to: 'empresas_pages#funcionarios_function', as: :funcionarios_function

  patch 'toggle_empregador/:id', to: 'empresas_pages#toggle_empregador', as: :toggle_empregador
  patch 'toggle_gestor/:id', to: 'empresas_pages#toggle_gestor', as: :toggle_gestor

  get 'consultants_outsourcing', to: 'consultants_pages#consultants_outsourcing', as: :consultants_outsourcing
  put 'habilitar_consultor/:consultant_id/:company_id', to: 'consultants_pages#enable_company', as: :habilitar_consultor

  resources :funcionarios_pages do
    collection do
      get :importar_funcionarios
      post :importar_funcionarios_create
    end
  end

  get 'vinculos_form/:id', to: 'funcionarios_pages#vinculos_form', as: :vinculos_form
  patch 'vinculos_form/:id', to: 'funcionarios_pages#vinculos_form_update', as: :vinculos_form_update
  patch 'desativar_vinculo', to: 'funcionarios_pages#desativar_vinculo', as: :desativar_vinculo

  get 'destroy_funcionario/:id', to: 'funcionarios_pages#destroy_funcionario', as: :destroy_funcionario

  resources :atestados

  get '/atestados_funcionario/:id', to: 'atestados#atestados_funcionario', as: :atestados_funcionario

  resources :okays, only: %i[index]

  post '/empresa_okay/:id', to: 'atestados#empresa_okay', as: :empresa_okay
  post '/funcionario_okay/:id', to: 'atestados#funcionario_okay', as: :funcionario_okay
  post '/empresa_subscrever/:id', to: 'atestados#empresa_subscrever', as: :empresa_subscrever
  post '/empresa_reverter/:id', to: 'atestados#empresa_reverter', as: :empresa_reverter

  resources :cfms, only: %i[new create]
  resources :importar_funcionarios, only: %i[index create]
  resources :bi_urls, only: %i[new create]

  get 'aceitar_lgpd', to: 'funcionarios_pages#show_lgpd'
  post 'update_lgpd', to: 'funcionarios_pages#update_lgpd'

  resources :password_resets

  get 'cid/buscar', to: 'cids#search', as: :cid_search

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :atestados, only: %i[index show]
      resources :funcionarios, only: %i[create]
      get 'opt', to: 'checks#verify_opt'
      get 'send_code', to: 'checks#send_email_with_code'
      post 'verify_code', to: 'checks#verify_code'
    end
  end

  resources :consultants, only: :index

  resources :collaborators, only: :index, path: 'colaboradores' do
    member do
      patch :authorize, path: 'autorizar'
      patch :revoke, path: 'revogar'
    end
  end

  get 'funcionarios_empresa', to: 'funcionarios_pages#funcionarios_empresa', as: 'funcionarios_empresa'

  get 'funcionarios_por_empresa/:id', to: 'atestados#funcionarios_por_empresa'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  resources :squads do
    collection do
      get :list
    end
  end
end
