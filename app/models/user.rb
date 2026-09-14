class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # friend    — a private page at /users/:id (self-or-admin only).
  # recruiter — the résumé at /cv (also open to admin).
  # admin     — me: everything.
  enum :role, { admin: 0, recruiter: 1, friend: 2 }, default: :friend, validate: true

  # Plain login handle — no email. Accounts are admin-created (no signup), so a
  # short slug is friendlier than an address.
  normalizes :username, with: ->(u) { u.strip.downcase }

  validates :username,
    presence: true,
    uniqueness: true,
    length: { in: 2..32 },
    format: { with: /\A[a-z0-9][a-z0-9_-]*\z/, message: "must be lowercase letters, digits, - or _" }

  # Optional — not used for login (that's :username). Blank normalizes to nil
  # so the unique index doesn't collide on empty strings.
  normalizes :email, with: ->(e) { e.strip.downcase.presence }

  validates :email,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    allow_nil: true

  # has_secure_password only checks presence (on create) and the 72-byte bcrypt
  # ceiling. Add a floor — the admin password comes straight from a secrets
  # manager, so this only ever catches a fat-fingered dev/seed value.
  validates :password, length: { minimum: 12 }, allow_nil: true

  # First-deploy admin bootstrap: create the admin from ADMIN_USERNAME /
  # ADMIN_PASSWORD (secrets manager -> deploy env) unless one already exists.
  # Idempotent — safe to call on every deploy. Returns a human-readable outcome.
  def self.bootstrap_admin_from_env
    return "admin already present" if exists?(role: :admin)

    username = ENV["ADMIN_USERNAME"].to_s.strip
    password = ENV["ADMIN_PASSWORD"].to_s
    return "ADMIN_USERNAME / ADMIN_PASSWORD unset — skipped" if username.empty? || password.empty?

    create!(username: username, password: password, role: :admin)
    "bootstrapped admin #{username.inspect}"
  end
end
