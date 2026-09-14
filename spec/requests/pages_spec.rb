require "rails_helper"

RSpec.describe "Pages", type: :request do
  fixtures :users

  def sign_in(user, password: "password")
    post session_path, params: { username: user.username, password: }
  end

  describe "GET /" do
    it "renders the home page without requiring authentication" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>menno.codes</title>")
      expect(response.body).to include('<h1 class="sr-only">menno.codes</h1>')
    end
  end

  describe "GET /about" do
    it "renders the about page" do
      get about_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>About · menno.codes</title>")
    end
  end

  describe "the primary nav" do
    it "links Home and About, marking the current page" do
      get root_path

      expect(response.body).to include(">Home</a>")
      expect(response.body).to include('href="/about"')
      expect(response.body).to include('aria-current="page"')
    end
  end

  describe "the footer auth links" do
    it "shows Sign in when signed out" do
      get root_path

      expect(response.body).to include(">Sign in<")
      expect(response.body).not_to include("Sign out")
    end

    it "shows My page / Sign out when signed in" do
      sign_in(users(:alice))
      get root_path

      expect(response.body).to include("My page")
      expect(response.body).to include("Sign out")
    end
  end

  describe "GET /cv" do
    it "redirects an anonymous visitor to sign in" do
      get cv_path

      expect(response).to redirect_to(new_session_path)
    end

    it "404s for a signed-in friend — access isn't revealed" do
      sign_in(users(:alice))
      get cv_path

      expect(response).to have_http_status(:not_found)
    end

    it "is visible to a recruiter" do
      sign_in(users(:recruiter))
      get cv_path

      expect(response).to have_http_status(:ok)
    end

    it "is visible to an admin" do
      sign_in(users(:admin))
      get cv_path

      expect(response).to have_http_status(:ok)
    end
  end
end
