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

  describe "GET /users/new" do
    it "404s for a signed-in friend" do
      sign_in(users(:alice))
      get new_user_path

      expect(response).to have_http_status(:not_found)
    end

    it "is visible to an admin" do
      sign_in(users(:admin))
      get new_user_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "lets an admin create a user" do
      sign_in(users(:admin))

      expect {
        post users_path, params: { user: { username: "erin", password: "supersecret123", role: "friend" } }
      }.to change(User, :count).by(1)

      expect(response).to redirect_to(users_path)
      expect(User.find_by(username: "erin")).to be_friend
    end

    it "re-renders the form on invalid input" do
      sign_in(users(:admin))

      expect {
        post users_path, params: { user: { username: "", password: "supersecret123", role: "friend" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "404s for a signed-in friend" do
      sign_in(users(:alice))

      expect {
        post users_path, params: { user: { username: "erin", password: "supersecret123", role: "friend" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /users/:id/edit" do
    it "404s for a signed-in friend" do
      sign_in(users(:alice))
      get edit_user_path(users(:dave))

      expect(response).to have_http_status(:not_found)
    end

    it "is visible to an admin" do
      sign_in(users(:admin))
      get edit_user_path(users(:alice))

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /users/:id" do
    it "lets an admin update a user" do
      sign_in(users(:admin))
      patch user_path(users(:alice)), params: { user: { role: "recruiter" } }

      expect(response).to redirect_to(users_path)
      expect(users(:alice).reload).to be_recruiter
    end

    it "re-renders the form on invalid input" do
      sign_in(users(:admin))
      patch user_path(users(:alice)), params: { user: { username: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "404s for a signed-in friend, even for their own account" do
      sign_in(users(:alice))
      patch user_path(users(:alice)), params: { user: { role: "admin" } }

      expect(response).to have_http_status(:not_found)
      expect(users(:alice).reload).to be_friend
    end
  end

  describe "DELETE /users/:id" do
    it "lets an admin delete another user" do
      sign_in(users(:admin))

      expect { delete user_path(users(:dave)) }.to change(User, :count).by(-1)
      expect(response).to redirect_to(users_path)
    end

    it "won't let an admin delete themselves" do
      sign_in(users(:admin))

      expect { delete user_path(users(:admin)) }.not_to change(User, :count)
      expect(response).to redirect_to(users_path)
    end

    it "404s for a signed-in friend" do
      sign_in(users(:alice))

      expect { delete user_path(users(:dave)) }.not_to change(User, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
