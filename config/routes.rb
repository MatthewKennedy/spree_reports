Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do

    resources :reports, only: [:index, :show] do
      collection do
        get :sales_total
        post :sales_total
        get :sales_by_store
        post :sales_by_store
      end
    end

  end
end
