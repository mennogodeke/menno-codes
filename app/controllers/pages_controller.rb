class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home about ]
  before_action :require_recruiter_or_admin, only: :cv

  def home
  end

  def about
  end

  # The résumé PDF. Visible to a recruiter or an admin; anyone else gets a
  # 404 — we don't confirm the page exists, same as the private /users/:id
  # pattern. Serves the real attached Cv#resume once one exists; falls back
  # to the committed placeholder until then.
  def cv
    if cv_resume&.attached?
      send_data cv_resume.download, filename: "menno-godeke-cv.pdf",
        type: "application/pdf", disposition: "inline"
    else
      send_file PLACEHOLDER_CV, filename: "menno-godeke-cv.pdf",
        type: "application/pdf", disposition: "inline"
    end
  end

  private
    PLACEHOLDER_CV = Rails.root.join("lib/assets/cv/placeholder.pdf")

    def cv_resume
      Cv.first&.resume
    end

    def require_recruiter_or_admin
      raise ActiveRecord::RecordNotFound unless Current.user.admin? || Current.user.recruiter?
    end
end
