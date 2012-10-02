namespace :create do
  desc "Create Robert's user account; email: klevo@klevo.sk password: nos1804"
  task "robert" do
    User.create first_name: "Robert", last_name: "S", password: "nos1804", password_confirmation: "nos1804", email: "klevo@klevo.sk"
  end
end
