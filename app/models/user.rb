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
end
