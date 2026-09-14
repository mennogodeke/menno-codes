require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with just a username and password" do
    expect(User.new(username: "bob", password: "supersecret123")).to be_valid
  end

  it "requires a username" do
    expect(User.new(password: "supersecret123")).not_to be_valid
  end

  it "strips and downcases the username" do
    user = User.create!(username: "  Bob  ", password: "supersecret123")
    expect(user.username).to eq("bob")
  end

  it "rejects a duplicate username" do
    User.create!(username: "bob", password: "supersecret123")
    expect(User.new(username: "bob", password: "supersecret123")).not_to be_valid
  end

  it "rejects a username with uppercase or symbol characters" do
    expect(User.new(username: "Bob!", password: "supersecret123")).not_to be_valid
  end

  describe "email" do
    it "is optional" do
      expect(User.new(username: "bob", password: "supersecret123", email: nil)).to be_valid
    end

    it "normalizes a blank value to nil" do
      user = User.create!(username: "bob", password: "supersecret123", email: "")
      expect(user.email).to be_nil
    end

    it "strips and downcases a present value" do
      user = User.create!(username: "bob", password: "supersecret123", email: "  Bob@Example.com ")
      expect(user.email).to eq("bob@example.com")
    end

    it "rejects an invalid format" do
      expect(User.new(username: "bob", password: "supersecret123", email: "not-an-email")).not_to be_valid
    end

    it "rejects a duplicate email" do
      User.create!(username: "bob", password: "supersecret123", email: "bob@example.com")
      dup = User.new(username: "carol", password: "supersecret123", email: "bob@example.com")
      expect(dup).not_to be_valid
    end

    it "allows more than one user with no email" do
      User.create!(username: "bob", password: "supersecret123")
      expect(User.new(username: "carol", password: "supersecret123")).to be_valid
    end
  end

  describe "role" do
    it "defaults to friend" do
      user = User.create!(username: "bob", password: "supersecret123")
      expect(user).to be_friend
    end

    it "exposes admin?/recruiter?/friend? predicates" do
      admin = User.create!(username: "bob", password: "supersecret123", role: :admin)
      recruiter = User.create!(username: "carol", password: "supersecret123", role: :recruiter)

      expect(admin).to be_admin
      expect(recruiter).to be_recruiter
    end

    it "rejects an unknown role" do
      # `validate: true` on the enum trades the default instant ArgumentError
      # for a normal validation failure — so an unknown value is invalid, not
      # a raise, on assignment.
      expect(User.new(username: "bob", password: "supersecret123", role: "ceo")).not_to be_valid
    end
  end

  describe "password" do
    it "rejects a password shorter than 12 characters" do
      expect(User.new(username: "bob", password: "short")).not_to be_valid
    end

    it "doesn't re-validate length on an unchanged password" do
      user = User.create!(username: "bob", password: "supersecret123")
      user.username = "bobby"

      expect(user).to be_valid
    end
  end

  describe ".bootstrap_admin_from_env" do
    around do |example|
      original = ENV.to_h.slice("ADMIN_USERNAME", "ADMIN_PASSWORD")
      example.run
      ENV["ADMIN_USERNAME"] = original["ADMIN_USERNAME"]
      ENV["ADMIN_PASSWORD"] = original["ADMIN_PASSWORD"]
    end

    it "creates an admin from ADMIN_USERNAME / ADMIN_PASSWORD" do
      # Fixture data loaded by other spec files can leave an admin-role row
      # sitting in the table outside the per-example transaction — force a
      # genuinely admin-free slate so this test's precondition actually holds.
      User.where(role: :admin).delete_all
      ENV["ADMIN_USERNAME"] = "menno"
      ENV["ADMIN_PASSWORD"] = "supersecret123"

      expect { User.bootstrap_admin_from_env }.to change(User, :count).by(1)
      expect(User.find_by(username: "menno")).to be_admin
    end

    it "is idempotent — does nothing if an admin already exists" do
      User.create!(username: "existing", password: "supersecret123", role: :admin)
      ENV["ADMIN_USERNAME"] = "menno"
      ENV["ADMIN_PASSWORD"] = "supersecret123"

      expect { User.bootstrap_admin_from_env }.not_to change(User, :count)
    end

    it "skips without raising when the env vars are unset" do
      ENV["ADMIN_USERNAME"] = nil
      ENV["ADMIN_PASSWORD"] = nil

      expect { User.bootstrap_admin_from_env }.not_to change(User, :count)
    end
  end
end
