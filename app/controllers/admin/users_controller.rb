class Admin::UsersController < ApplicationController
  layout 'admin', :except => :init

	before_filter :authorize_admin, :except => [:login, :logout, :init]
	
	def index
		@title = 'User list'
    @users = User.find_by_read_level_with_order(params[:read_level], params[:order])
	  @sub_title = params[:read_level]
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 30 if params[:per_page].blank?
    @users = @users.paginate(:page => params[:page], :per_page => params[:per_page])
	end
	
	def new
    @user = User.new(:name=>'guest')
    params[:from] = 'new'
    render :action => "modification"
	end

	def create
    @user = User.new(params[:user])
    begin
      @user.save!
    rescue
      params[:from] = 'new'
      render :action => "modification"
    else
      redirect_to admin_users_url
    end
	end
	
	def edit
    @user = User.find(params[:id])
    params[:from] = 'edit'
    render :action => "modification"
	end
	
	def update
    @user = User.find(params[:id])
    begin
    	@user.update_property(params[:user])
    rescue
      params[:from] = 'edit'
      render :action => "modification"
    else
      redirect_to admin_users_url
    end
	end
	
	def destroy
    begin
      User.transaction do
      	params[:selected_id].each{|id|
      		next if session[:user_id] == id.to_i
      		User.find(id).destroy
      	}
      end
		end
		redirect_to admin_users_url(:read_level => params[:read_level])
	end
	
	def login
    if request.post?
      session[:user_id] = nil
      session[:user_read_level] = nil
      user = User.authenticate(params[:password])
      if user
        session[:user_id] = user.id
        session[:user_read_level] = user.read_level
        temp = Time.now
        if user.span != 0
        	user.update_attributes!(:end_time => user.span.minutes.from_now(temp))
        end
      end
      redirect_to root_url
    end
	end
	
	def logout
		user = User.find(params[:id])
		user.destroy if not params[:time_out].blank? and params[:time_out] == 'true'
    session[:user_id] = nil
    session[:user_read_level] = nil
    redirect_to root_path
	end
	
	def init
		unless User.first
			if not params[:init].blank? and params[:init] == 'create'
		    @user = User.new(params[:user])
	     	@user.read_level = 0
	    	@user.span = 0
		    begin
		      @user.save!
		    rescue
					redirect_to :back
			  else
		      session[:user_id] = @user.id
		      session[:user_read_level] = @user.read_level
		      redirect_to admin_root_url
		    end
			else
				@user = User.new
			end
		else
			redirect_to admin_root_url
		end
	end
end
