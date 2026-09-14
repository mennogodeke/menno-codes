module ApplicationHelper
  SITE_NAME = "menno.codes"

  # "menno.codes" on pages that don't set a title; "<Title> · menno.codes" elsewhere.
  def page_title
    title = content_for(:title)
    title.present? ? "#{title} · #{SITE_NAME}" : SITE_NAME
  end
end
