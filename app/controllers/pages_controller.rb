class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home about ]
  before_action :require_recruiter_or_admin, only: :cv

  def home
  end

  def about
  end

  # The résumé. Visible to a recruiter or an admin; anyone else gets a 404 —
  # we don't confirm the page exists, same as the private /users/:id pattern.
  def cv
  end

  private
    def require_recruiter_or_admin
      raise ActiveRecord::RecordNotFound unless Current.user.admin? || Current.user.recruiter?
    end
end
