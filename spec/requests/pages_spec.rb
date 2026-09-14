require "rails_helper"

RSpec.describe "Pages", type: :request do
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
end
