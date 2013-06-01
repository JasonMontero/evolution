class UsersController < ApplicationController
  before_filter :need_admin!, :only => [:new, :create]

  # for demo assessment process TODO: revisit it
  def mgr_assessments
    @menu_category = 'manager'
    @menu_active = 'assess'

    @user = User.find(params[:id])
  end

  def assessment
    @menu_category = 'manager'
    @menu_active = 'assess'

    @user = User.find(params[:id])
    session[:return_to] = request.referer
  end

  def update_assessment
    @user = User.find(params[:id])
    @user.is_assessed = true
    respond_to do |format|
      if @user.save
        format.html { redirect_to session.delete(:return_to), notice: 'User assessment is finished.'}
      else
        format.html { redirect_to :back, notice: 'Update user assessment error.'}
      end
    end
  end

  def dashboard
    @menu_category = 'user'
    @menu_active = 'home' 
    @pending_courses = Course.for_position(current_user.position).first(3)
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.order(:id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @menu_category = current_user.admin? ? 'admin' : 'user'
    @menu_active = current_user.admin? ? 'users' : 'profile' 

    @user = User.find(params[:id])
    @pending_courses = Course.for_position(@user.position).page(params[:page])
    @teach_courses = Course.for_teacher(@user).page(params[:page])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @menu_category = 'admin'
    @menu_active = 'users'
    @user = User.new
    session[:return_to] = request.referer

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    if current_user.admin?
      @menu_category = 'admin'
      @menu_active = 'users'
    else
      @menu_category = 'user'
      @menu_active = 'profile'
    end
    @user = User.find(params[:id])
    session[:return_to] = request.referer
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to session.delete(:return_to), notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to session.delete(:return_to), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to :back, :notice => "user has been deleted."}
      format.json { head :no_content }
    end
  end

  #POST /users/import
  def import
    User.import(params[:file])
    redirect_to :back, notice: "Users has successfully imported."
    rescue ActionController::RedirectBackError
      redirect_to root_path
    
  end

  def export
    @users = User.order(:staff_id)
    puts "*************************"
    respond_to do |format|
      format.html {redirect_to :back, notice: "Export format not currect. Support: CSV, Excel." }
      format.csv { send_data @users.to_csv, :type => "text/csv" }
    end
  end
end