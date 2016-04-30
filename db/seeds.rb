# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require "vcr"

# Load seed helpers and data
Dir[File.join(Rails.root, "db", "seeds", "*.rb")].sort.each { |seed| load seed }

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

# Create alice and bob users
def create_alice_and_bob
  User.without_callback(:create, :after, :send_welcome_email) do
    alice = User.find_or_create_by({:email=>"alice@example.com", :first_name => "Alice", :last_name => "Jones"})
    alice.password = "password" if alice.encrypted_password.blank?
    alice.save!

    bob = User.find_or_create_by({:email=>"bob@example.com", :first_name => "Bob", :last_name => "Jones"})
    bob.password = "password" if bob.encrypted_password.blank?
    bob.save!
    return [alice, bob]
  end
end

# Create example users
def create_example_users
  100.times do |n|
    first_name = pick_first_name
    email = "#{first_name}_#{n}@example.com"
    User.without_callback(:create, :after, :send_welcome_email) do
      user = User.find_or_create_by({:email => email.downcase, :first_name => first_name, :last_name => "Example #{n}"})
      user.password = "password" if user.encrypted_password.blank?
      user.save!
    end
  end
end

# Seed db with slyps
def seed_slyps
  VCR.use_cassette("slyp_seeds", :record => :all) do
    @slyp_seed_urls.each do |url|
      Slyp.fetch(url)
    end
  end
end

# Generate bulk reslyps
def generate_bulk_reslyps_and_replies
  100.times do |n|
    reslyp(@alice, pick_user(@alice.id))
    reslyp(@bob, pick_user(@bob.id))
    reslyp(pick_user(@alice.id), @alice)
    reslyp(pick_user(@bob.id), @bob)
    reslyp(pick_user) # Potential for conflict but meh
  end
end

################################### EXECUTE ###################################
seed_slyps

if ENV["RACK_ENV"] == "development"
  @alice, @bob = create_alice_and_bob
  create_example_users
  generate_bulk_reslyps_and_replies
end

