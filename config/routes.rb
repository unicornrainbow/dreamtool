require 'sidekiq/web'

Press::Application.routes.draw do

  # match 'new artboard' => 'artboards#new'
  # get
  # لثف "شثهخع" خ
  match 'editions/import', via: [:get, :post]

  get 'pub/:name',
    controller: :publications,
    action: :show_by_name

  root 'home#index'

  get  :composer, controller: :editions

  devise_for :users, controllers: { sessions: "sessions" }

  resources :editions do
    resources :sections
    resources :content_items
    resources :pages
    resources :groups
    resources :sections
    resource :masthead_artwork, controller: 'edition_masthead_artworks'
    resources :prints, only: ['index', 'create'] do
      member do
        get '(*path)' => :show, as: 'show'
      end
    end

    member do
      get  :render_content_item, controller: :content_items
      post :render_text_area,    controller: :content_items
      get  :render_page,         controller: :pages
      get  :compose
      get  :wip
      asset_routes = lambda do
        get 'fonts/*path'       => :fonts
        get 'images/*path'      => :images
        get 'videos/*path'      => :videos
        get 'javascripts/*path' => :javascripts
        get 'stylesheets/*path' => :stylesheets
      end
      scope 'compose' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :compose, :defaults => { :format => "html" }
      end
      get :preview
      scope 'preview' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :preview, :defaults => { :format => "html" }
      end
      get :tearout
      scope 'tearout' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :tearout, :defaults => { :format => "html" }
      end
      get :download

      scope 'compile' do
        scope controller: :edition_assets, &asset_routes
        get '*path' => :compile, :defaults => { :format => "html" }
      end
    end
  end

  post '/' => 'home#sign_in', as: 'signin'
  get '/sign-out' => 'home#sign_out'
  get '/hot-muffins' => 'home#hot_muffins'
  post '/hot-muffins' => 'home#hot_muffins'
  get '/signup' => 'signups#new', as: 'signup'
  post '/signup' => 'signups#create'
  # post '/tryme' => '
  post '/workspace' => 'workspaces#save_workspace'
  get '/dash' => 'dash#index'


  get 'flickr/authorize'
  get 'flickr/auth_callback'
  get 'flickr/photos'

  resources :prints, except: 'show' do
    member do
      get :download
      put :publish
      get 'view/*path' => :view, :defaults => { :format => "html" }
    end
  end

  resources :mastheads do
    member do
      get :preview
    end
  end

  resources :stories
  resources :photos
  resources :videos do
    member do
      post :set_cover
    end
  end

  resources :layouts
  resources :partials
  resources :inlets
  resources :content_regions do
    member do
      put :move
    end
  end
  resources :publications
  resources :content_items do
    collection do
      get :form
    end
  end
  resources :pages do
    member do
      get :preview
    end
  end

  resources :sections do
    resources :pages
    member do
      get :preview
    end
  end

  resources :fonts

  namespace :api do
    resources :story_text_content_items, only: [:create, :update]
  end

  namespace :admin do
    resources :users
    resources :organizations
  end

  get 'dev/edit'
  get 'dev/map'
  get 'dev/tree/*path' => 'dev#tree'
  get 'dev/browse/*path' => 'dev#browse'

  get '/logo' => 'application#logo'

  scope controller: :webpages do
    get :lbs_demo
  end

  mount Sidekiq::Web, at: "/sidekiq"

  get '/breakdance' => 'breakdance#info'
  get '/breakdance/on' => 'breakdance#on'
  get '/breakdance/off' => 'breakdance#off'

  # Active 404
  # match "*a", :to => "application#routing_error", via: [:get, :post]

end
