ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
	# map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'

  map.root :controller => 'albums', :action => 'top'
  map.top_rss '/albums.rss', :controller => 'albums', :action => 'albums'
  map.connect '/top_shown_new.xml', :controller => 'albums', :action => 'top_shown_new'
  map.connect '/top_shown_all.rss', :controller => 'albums', :action => 'top_shown_all'
  map.connect '/:year', :controller => "albums", :action => "show", :year => /\d{4}/
  map.connect '/:dirname/contents/:content_name',
              :controller => 'contents',
              :action => 'show',
              :dirname => /\d{8}.+/,
#/
              :content_name => /.+\.(jpg|jpeg|bmp|png|gif)/i
  map.connect '/:dirname', :controller => 'albums', :action => 'show', :dirname => /\d{8}.+/
#/

  map.connect '/udpate_timer', :controller => 'application', :action => 'update_timer'
  


  map.namespace :admin do |admin|
  	admin.root :controller => 'albums', :action => 'index'
    admin.resources :albums, :collection => {:batch_action => :post}, :member => {:rate => :post, :t_publish => :get}, :except => [:show, :destroy] do |albums|
      albums.resources :contents, :collection => {:batch_action => :post, :sort => :get, :save_sort => :post, :upload => :post}, :member => {:rate => :post, :oncover => :get}, :except => [:show, :destroy]
    end
    admin.resources :users, :collection => {:login => :post, :logout => :get, :init => :get}, :except => [:show]
    admin.resources :comments, :only => [:index, :edit, :update], :collection => {:batch_delete => :post}
    admin.connect "/settings", :controller => "settings", :action => "edit"
    admin.connect "/settings/update", :controller => "settings", :action => "update"
  end
  
  map.resources :albums, :member => {:comment => :post}, :only => [] do |albums|
  	albums.connect 'cooliris/:id', :controller => 'albums', :action => 'cooliris'
  	albums.resources :contents, :member => {:comment => :post}, :only => []
  end
end
