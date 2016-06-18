# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup)
require "vcr"

# Load seed helpers and data
Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each { |seed| load seed }

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

# Create alice and bob users
def create_alice_and_bob
  @alice = create_user_softly("alice@example.com", "Alice", "Jones")
  @bob = create_user_softly("bob@example.com", "Bob", "Jones")
end

def create_user_softly(email, first_name, last_name)
  User.without_callback(:create, :after, :send_welcome_email) do
    user = User.find_or_create_by(
      email: email,
      first_name: first_name,
      last_name: last_name
    )
    user.password = "password" if user.encrypted_password.blank?
    user.save!
    user
  end
end

# Create example users
def create_example_users
  100.times do |n|
    first_name = pick_first_name
    email = "#{first_name}_#{n}@example.com"
    create_user_softly(email.downcase, first_name, "Example #{n}")
  end
end

# Seed db with slyps
def seed_slyps
  VCR.use_cassette("slyp_seeds", record: :all) do
    $stdout.sync = true
    print "Creating slyps: "
    @slyp_seed_urls.each do |url|
      print Slyp.fetch(url).valid? ? ".".green : "F".red
      sleep 1
    end
  end
end

# Generate bulk reslyps
def generate_bulk_reslyps_and_replies
  100.times do
    perform_reslyp(@alice, pick_user(@alice.id))
    perform_reslyp(@bob, pick_user(@bob.id))
    perform_reslyp(pick_user(@alice.id), @alice)
    perform_reslyp(pick_user(@bob.id), @bob)
    perform_reslyp(pick_user) # Potential for conflict but meh
  end
end

################################### EXECUTE ###################################
seed_slyps
if ENV["RACK_ENV"] == "development"
  create_alice_and_bob
  create_example_users
  generate_bulk_reslyps_and_replies
end
