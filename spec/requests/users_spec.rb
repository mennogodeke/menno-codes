require "rails_helper"

RSpec.describe "Users", type: :request do
  fixtures :users

  def sign_in(user, password: "password")
    post session_path, params: { username: user.username, password: }
  end

  describe "GET /users/:id" do
    it "redirects an anonymous visitor to sign in" do
      get user_path(users(:alice))

      expect(response).to redirect_to(new_session_path)
    end

    it "lets a friend see their own page" do
      sign_in(users(:alice))
      get user_path(users(:alice))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("alice")
    end

    it "404s when a friend asks for someone else's page" do
      sign_in(users(:alice))
      get user_path(users(:dave))

      expect(response).to have_http_status(:not_found)
    end

    it "lets an admin see any user's page" do
      sign_in(users(:admin))
      get user_path(users(:alice))

      expect(response).to have_http_status(:ok)
    end

    it "404s for an unknown id rather than revealing nothing exists" do
      sign_in(users(:admin))
      get "/users/999999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /users" do
    it "redirects an anonymous visitor to sign in" do
      get users_path

      expect(response).to redirect_to(new_session_path)
    end

    it "404s for a signed-in friend" do
      sign_in(users(:alice))
      get users_path

      expect(response).to have_http_status(:not_found)
    end

    it "404s for a signed-in recruiter" do
      sign_in(users(:recruiter))
      get users_path

      expect(response).to have_http_status(:not_found)
    end

    it "lists every user for an admin" do
      sign_in(users(:admin))
      get users_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("alice")
      expect(response.body).to include("dave")
      expect(response.body).to include("recruiter")
      expect(response.body).to include("admin")
    end
  end
end
