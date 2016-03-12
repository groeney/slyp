# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require "vcr"

# Bag of slyp urls
@slyp_seed_urls = [
  "http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/",
  "http://www.xconomy.com/san-francisco/2014/01/08/could-a-little-startup-called-diffbot-be-the-next-google/2/",
  "https://en.wikipedia.org/wiki/Great_Heathen_Army",
  "https://www.reddit.com/r/pics/comments/48irzy/i_learned_how_to_work_better_today_on_my_way_to/",
  "https://www.farnamstreetblog.com/2016/02/shane-parrish-mental-models/?foo=1234&bar=5678",
  "https://medium.com/life-tips/dear-girl-who-appears-to-work-everywhere-7004ddeda2dc#.posvfl9oz",
  "http://redef.com/original/age-of-abundance-how-the-content-explosion-will-invert-the-media-industry",
  "https://www.youtube.com/watch?v=DLhRFcUehm4",
  "https://medium.com/life-tips/be-normal-at-dinner-on-geniuses-lovers-and-the-asks-we-make-of-both-ecbe29b02f35#.j9ijguaxk",
  "http://www.huffingtonpost.com/life-by-dailyburn-/beer-after-workout_b_7696806.html",
  "http://blog.ideashower.com/post/21276590202/why-pocket-went-free",
  "https://www.youtube.com/watch?v=-MoLdQA7aSg",
  "http://www.vox.com/2015/7/8/8908765/chinas-stock-market-crash-explained/in/8677926",
  "http://www.theguardian.com/commentisfree/2015/jun/25/qa-is-the-symbol-of-high-kevinism-and-should-be-interred-with-rudds-memory",
  "http://blog.ted.com/machines-that-learn-a-recap-of-session-3-at-ted2015/",
  "http://www.nytimes.com/2015/06/23/opinion/when-an-apology-is-anything-but.html?mabReward=A4&moduleDetail=recommendations-2&action=click&contentCollection=U.S.&region=Footer&module=WhatsNext&version=WhatsNext&contentID=WhatsNext&configSection=article&isLoggedIn=false&src=recg&pgtype=article&_r=0",
  "https://www.foreignaffairs.com/articles/china/2015-04-20/what-it-means-be-chinese",
  "http://www.newyorker.com/magazine/2015/03/09/travels-with-my-censor",
  "http://www.newyorker.com/magazine/2015/06/22/the-death-treatment",
  "https://en.wikipedia.org/wiki/The_Electric_Kool-Aid_Acid_Test",
  "http://www.newyorker.com/magazine/2015/05/18/tomorrows-advance-man",
  "http://paulromer.net/mathiness/",
  "http://www.newyorker.com/magazine/2015/05/18/lighting-the-brain",
  "https://www.facebook.com/berniesanders/videos/925757774145894/",
  "https://www.youtube.com/watch?v=eEfxalQNwKY"
]

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :faraday
end

# Bag of comments
@comments = [
  "thought you'd like this",
  "thought you'd appreciate this",
  "robots are taking over!",
  "the world has gone mad",
  "what do you think of this?",
  "check this out",
  "this is insane",
  "related to yesterday discussion",
  "is this what you were talking about yesterday?",
  "WILD!",
  "totally hilarious",
  "game changer",
  "you are a genius"
]

# Bag of first names
@first_names = [
  "Alex",
  "Greg",
  "Tom",
  "Wilson",
  "Morgan",
  "Mille",
  "Ian",
  "Xander",
  "Drew",
  "Arturo",
  "Franky",
  "Anja",
  "Adrienne"
]

# Create alice and bob users
def create_alice_and_bob()
  alice = User.find_or_create_by({:email=>"alice@example.com", :first_name => "Alice", :last_name => "Jones"})
  if alice.encrypted_password.blank?
    alice.password = "password"
    alice.save!
  end

  bob = User.find_or_create_by({:email=>"bob@example.com", :first_name => "Bob", :last_name => "Jones"})
  bob.password = "password" if bob.encrypted_password.blank?
  bob.save!
  return [alice, bob]
end

# Create example users to generate reslyps
def create_example_users()
  1000.times do |n|
    first_name = @first_names[n % @first_names.length]
    email = "#{first_name}_#{n}@example.com"
    user = User.find_or_create_by({:email => email.downcase, :first_name => first_name, :last_name => "Example #{n}"})
    user.password = "password" if user.encrypted_password.blank?
    user.save!
  end
end

# Seed db with slyps
def seed_slyps()
  VCR.use_cassette("slyp_seeds") do
    @slyp_seed_urls.each do |url|
      Slyp.fetch({:url => url})
    end
  end
end

# Generate bulk reslyps
def generate_bulk_reslyps()
  users = User.all
  slyps = Slyp.all
  num_users = users.length
  num_slyps = slyps.length

  100.times do |n|
    slyp_index = Random.rand(num_slyps)
    slyp = slyps[slyp_index]

    alice_user_slyp = @alice.user_slyps.find_or_create_by({:slyp_id => slyp.id})
    bob_user_slyp = @bob.user_slyps.find_or_create_by({:slyp_id => slyp.id})

    user_1_index = Random.rand(num_users)
    user_1 = users[user_1_index]
    user_1_slyp = user_1.user_slyps.find_or_create_by({:slyp_id => slyp.id})

    # Generate reslyps to alice and bob
    comment_index = Random.rand(@comments.length)
    comment = @comments[comment_index]
    user_1.send_slyp({
      :email => @alice.email,
      :slyp_id => slyp.id,
      :comment => comment
      })
    user_1.send_slyp({
      :email => @bob.email,
      :slyp_id => slyp.id,
      :comment => comment
      })

    user_2_index = Random.rand(num_users)
    user_2 = users[user_2_index]

    # Generate reslyps for user_1 and user_2
    user_1.send_slyp({
      :email => user_2.email,
      :slyp_id => slyp.id,
      :comment => comment
      })

    # Generate reslyps from alice or bob
    @alice.send_slyp({
      :email => user_2.email,
      :slyp_id => slyp.id,
      :comment => comment
      })
    @bob.send_slyp({
      :email => user_2.email,
      :slyp_id => slyp.id,
      :comment => comment
      })
  end
end

@alice, @bob = create_alice_and_bob()
create_example_users()
seed_slyps()
generate_bulk_reslyps()


