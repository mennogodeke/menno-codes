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
end
