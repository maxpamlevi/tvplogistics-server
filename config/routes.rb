# frozen_string_literal: true

# == Route Map
#

Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/sessions'
      }

      resources :dashboard do
        member do
          post :update_result
          get :get_so
        end
        collection do
          post :return_data
          post :update_status
          post :get_user_info
          post :remove
          post :report
        end
      end


      resources :informations do
        collection do
          get :vendors
          get :customers
          post :remove
        end
      end


      resources :debit_notes do
        collection do
          post :remove
          get :get_pdf
          post :submit
          post :return_data
        end
      end

      resources :payment_requests do
        collection do
          post :remove
          get :get_pdf
          post :submit
          post :return_data
        end
      end

    end
  end

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  root 'home#index'
  # root 'service_order#index'

  get '/tvpl' => 'home#index'
  get 'page-about-us' => 'home#about_us'
  get 'page-pricing' => 'home#pricing'
  get 'page-faq' => 'home#faq'
  get 'page-contact' => 'home#contact'
  get 'page-news' => 'home#news'
  get 'page-logistics-service' => 'home#logistics_service'
  get 'page-leadership' => 'home#leadership'
  get 'page-careers' => 'home#careers'

  get 'contact' => 'home#contact'
  get 'logistics_service' => 'home#logistics_service'
  get 'pricing' => 'home#pricing'
  get 'faq' => 'home#faq'
  get 'about_us' => 'home#about_us'
  get 'careers' => 'home#careers'

  scope 'dashboard' do
    get '' => 'service_order#dashboard', as: 'dashboard'
    get 'new' => 'service_order#new'
    post 'create' => 'service_order#create', as: 'dashboard_create'
    get 'edit/:id' => 'service_order#edit', as: 'dashboard_edit'
    post 'update/:id' => 'service_order#update', as: 'dashboard_update'

    get 'delete/:id' => 'service_order#delete', as: 'dashboard_delete'
    get 'rollback/:id' => 'service_order#rollback', as: 'dashboard_rollback'
    get 'change_status/:id' => 'service_order#change_status', as: 'dashboard_change_status'
    get 'data' => 'service_order#data', as: 'dashboard_data'
  end

  resource :business_plans do
    get 'data' => 'business_plans#data'
    post 'update_attr' => 'business_plans#update_attr'
    get 'update_done_so/:id' => 'business_plans#update_done_so'
  end

  resources :file_data do
    post 'add_data' => 'file_data#add_data'
    get 'truck/:id' => 'file_data#truck', on: :collection
    get 'barge/:id' => 'file_data#barge', on: :collection
    get 'load/:id' => 'file_data#load', on: :collection
    get 'discharge/:id' => 'file_data#discharge', on: :collection
    get 'internal/:id' => 'file_data#internal', on: :collection
    get 'external/:id' => 'file_data#external', on: :collection
    get 'so_disc/:id' => 'file_data#so_disc', on: :collection
    get 'so_load/:id' => 'file_data#so_load', on: :collection
    get 'so_cont/:id' => 'file_data#so_cont', on: :collection
    get 'so_bk/:id' => 'file_data#so_bk', on: :collection
    post 'update_result', on: :collection
    post 'upload_file', on: :collection
  end

  resources :payment_requests do
    post 'add_data'
    get 'edit/:id' => 'payment_requests#edit'
    get 'data', on: :collection
    get 'list', on: :collection
    post 'update_attr', on: :collection
    post 'create_pr_without_so', on: :collection
    post 'update_done_status', on: :collection
    post 'remove_row', on: :collection
  end

  resources :debit_notes do
    get 'edit/:id' => 'debit_notes#edit'
    get 'data', on: :collection
    get 'list', on: :collection
    post 'update_attr', on: :collection
    post 'create_pr_without_so', on: :collection
    post 'update_done_status', on: :collection
    post 'remove_row', on: :collection
  end

  resources :informations, only: [:index] do
    get 'vendors', on: :collection
    post 'add_data', on: :collection
    post 'update_attr', on: :collection
    get 'customers', on: :collection
    post 'vendors', on: :collection
    post 'customers', on: :collection
  end

  get 'activity' => 'service_order#activity'
  get 'analytics' => 'service_order#analytics'
  get 'profit' => 'service_order#profit'
  get 'pivot' => 'service_order#pivot'
  get 'analytics/data' => 'service_order#data_analytics'
  get 'quote' => 'service_order#quote'


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
end
