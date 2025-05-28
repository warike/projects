Workspace::Application.routes.draw do
  resources :entries do
    collection { post :sort }
  end
  resources :activities
  resources :reviews
  resources :members
  resources :pivots


  devise_for :users, controllers: { invitations: 'devise/invitations', omniauth_callbacks: "omniauth_callbacks" }
  resources :startups
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'discover' => 'startups#published', as: :startups_published
  get 'create_review' => 'startups#create_review'
  get 'dashboard' => 'dashboard#index'
  get 'create_pivot/:id' => 'dashboard#create_pivot'
  get 'dashboard/:id' => 'dashboard#view' , as: :dashboard_startup
  get 'dashboard/:id/edit' => 'dashboard#edit', as: :edit_dashboard_startup
  post 'dashboard/invite_user' => 'dashboard#invite_user'
  post 'dashboard/:id/update' => 'dashboard#update'
  get 'error403' => 'welcome#noautorizado'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
