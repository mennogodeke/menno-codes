require "rails_helper"

RSpec.describe "Authentication", type: :request do
  fixtures :users

  let(:alice) { users(:alice) }

  def sign_in(user, password: "password")
    post session_path, params: { username: user.username, password: }
  end

  describe "GET /session/new" do
    it "renders the sign-in page" do
      get new_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    it "signs a user in" do
      sign_in(alice)

      # No root route yet — asserted once Home lands. Success here means a
      # session got created and the controller redirected somewhere.
      expect(response).to have_http_status(:found)
      expect(alice.sessions.count).to eq(1)
    end

    it "rejects a bad password without creating a session" do
      sign_in(alice, password: "wrong")

      expect(response).to redirect_to(new_session_path)
      expect(alice.sessions.count).to eq(0)
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      sign_in(alice)
      delete session_path

      expect(response).to redirect_to(new_session_path)
      expect(alice.sessions.count).to eq(0)
    end
  end
end
