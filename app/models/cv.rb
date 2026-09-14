# The résumé PDF served at /cv. Deliberately thin — a singleton attachment
# anchor for now (Cv.first_or_create!), not the role-tailored/admin-editable
# CV system that may replace v1's cv-engine later.
class Cv < ApplicationRecord
  has_one_attached :resume
end
