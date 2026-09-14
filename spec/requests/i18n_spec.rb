require "rails_helper"

RSpec.describe "i18n", type: :request do
  describe "GET /" do
    it "renders English by default" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<html lang="en"')
      expect(response.body).to include("Backend and infrastructure engineer")
    end
  end

  describe "GET /nl" do
    it "renders the Dutch home page" do
      get "/nl"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<html lang="nl"')
      expect(response.body).to include("Backend- en infrastructure-engineer")
    end
  end

  describe "GET /de" do
    it "renders the German home page" do
      get "/de"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<html lang="de"')
      expect(response.body).to include("Backend- und Infrastructure-Engineer")
    end
  end

  describe "GET /nl/about" do
    it "renders the Dutch about page" do
      get "/nl/about"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>Over mij · menno.codes</title>")
      expect(response.body).to include("Ik ben backend- en infrastructure-engineer")
    end
  end

  describe "GET /de/about" do
    it "renders the German about page" do
      get "/de/about"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>Über mich · menno.codes</title>")
      expect(response.body).to include("Ich bin Backend- und Infrastructure-Engineer")
    end
  end

  describe "GET /en" do
    it "doesn't exist — English is unprefixed only, no duplicate URL" do
      get "/en"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "the nav on a translated page" do
    it "links to the same locale's About page" do
      get "/nl"

      expect(response.body).to include('href="/nl/about"')
    end

    it "links back to unprefixed English from About" do
      get "/nl/about"

      expect(response.body).to include('href="/nl"')
    end
  end

  describe "the footer on a translated page" do
    it "shows translated auth links" do
      get "/nl"

      expect(response.body).to include(">Inloggen<")
    end
  end

  describe "routes outside the locale scope" do
    it "sign-in stays unprefixed and English regardless of a prior locale" do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<html lang="en"')
    end

    it "doesn't show a locale switcher — nothing there has translations" do
      get new_session_path

      expect(response.body).not_to include("switcher")
    end
  end

  describe "the locale switcher" do
    it "offers EN/NL/DE on Home, marking the current one" do
      get root_path

      expect(response.body).to include('class="switcher__opt is-active" href="/">EN</a>')
      expect(response.body).to include('class="switcher__opt" href="/nl">NL</a>')
      expect(response.body).to include('class="switcher__opt" href="/de">DE</a>')
    end

    it "switches to the same page in another locale, not back to Home" do
      get "/nl/about"

      expect(response.body).to include('class="switcher__opt" href="/about">EN</a>')
      expect(response.body).to include('class="switcher__opt is-active" href="/nl/about">NL</a>')
      expect(response.body).to include('class="switcher__opt" href="/de/about">DE</a>')
    end
  end
end
