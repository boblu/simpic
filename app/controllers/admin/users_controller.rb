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
      user = User.authenticate(params[:password])
      if user
        if user.span == -100
          session[:user_id] = user.id
        elsif user.span >= 0
          user.update_attributes!(:end_time => user.span.seconds.from_now(Time.now))
          session[:user_id] = user.id
        else
          user.destroy
          flash[:error] = "Wrong password!"
        end
      else
        flash[:error] = "Wrong password!"
      end
      redirect_to get_named_locale_path_or_url('root_url')
    end
	end
	
	def logout
		user = User.find(session[:user_id])
		unless user.end_time.blank?
	    if user.end_time <= (1).seconds.from_now(Time.now)
			  user.destroy
			else
	      user.update_attributes!(:span => (user.end_time.to_i - Time.now.to_i), :end_time => nil)
	    end
	  end
    session[:user_id] = nil
    redirect_to get_named_locale_path_or_url('root_url')
	end
	
	def init
		unless User.first
			if not params[:init].blank? and params[:init] == 'create'
		    @user = User.new(params[:user])
	     	@user.read_level = 0
	    	@user.span = -100
		    begin
		      @user.save!
		    rescue
					redirect_to :back
			  else
		      session[:user_id] = @user.id
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
