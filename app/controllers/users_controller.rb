class UsersController < ApplicationController
  before_action :require_admin, only: :index

  # Admin only.
  def index
    @users = User.order(:username)
  end

  # One private friend page. Visible only to the user themselves or an admin;
  # anyone else gets a 404 — we don't confirm the id exists.
  def show
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound unless Current.user == @user || Current.user.admin?
  end

  private
    def require_admin
      raise ActiveRecord::RecordNotFound unless Current.user.admin?
    end
end
