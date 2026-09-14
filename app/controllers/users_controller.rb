class UsersController < ApplicationController
  before_action :require_admin, only: %i[ index new create edit update destroy ]

  # Admin only.
  def index
    @users = User.order(:username)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: "#{@user.username} created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # One private friend page. Visible only to the user themselves or an admin;
  # anyone else gets a 404 — we don't confirm the id exists.
  def show
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound unless Current.user == @user || Current.user.admin?
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: "#{@user.username} updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Accounts are admin-created and admin-managed — no self-service, so an
  # admin can't delete their own account and lock themselves out.
  def destroy
    @user = User.find(params[:id])
    if @user == Current.user
      redirect_to users_path, alert: "You can't delete your own account."
    else
      @user.destroy
      redirect_to users_path, status: :see_other, notice: "#{@user.username} deleted."
    end
  end

  private
    def require_admin
      raise ActiveRecord::RecordNotFound unless Current.user.admin?
    end

    def user_params
      params.require(:user).permit(:username, :email, :role, :password)
    end
end
