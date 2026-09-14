# Accounts are admin-created — there's no signup route. In production, the
# admin is bootstrapped from ADMIN_USERNAME / ADMIN_PASSWORD (secrets
# manager -> deploy env); everywhere else, seed a working local admin plus
# one of each role for testing the gated pages by hand.
if Rails.env.production?
  puts User.bootstrap_admin_from_env
else
  User.find_or_create_by!(username: "admin") { |u| u.password = "supersecret123"; u.role = :admin }
  User.find_or_create_by!(username: "recruiter") { |u| u.password = "supersecret123"; u.role = :recruiter }
  User.find_or_create_by!(username: "friend") { |u| u.password = "supersecret123"; u.role = :friend }
end
