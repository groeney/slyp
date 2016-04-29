# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require "vcr"

# Bag of slyp urls
@slyp_seed_urls = ["http://codeinthehole.com/writing/pull-requests-and-other-good-practices-for-teams-using-github/",
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
 "http://www.nytimes.com/2015/06/23/opinion/when-an-apology-is-anything-but.html?mabReward=A4&moduleDetail=recommendations-2&action=click&contentCollection=U.S.&region=Footer&module=WhatsNext&version=WhatsNext&contentID=WhatsNext&configSection=article&isLoggedIn=false&src=recg&pgtype=article&_r=1",
 "http://www.newyorker.com/magazine/2015/03/09/travels-with-my-censor",
 "http://www.newyorker.com/magazine/2015/06/22/the-death-treatment",
 "https://en.wikipedia.org/wiki/The_Electric_Kool-Aid_Acid_Test",
 "http://www.newyorker.com/magazine/2015/05/18/tomorrows-advance-man",
 "http://www.newyorker.com/magazine/2015/05/18/lighting-the-brain",
 "https://www.facebook.com/berniesanders/videos/925757774145894/",
 "https://www.youtube.com/watch?v=eEfxalQNwKY",
 "https://www.foreignaffairs.com/articles/china/2015-04-20/what-it-means-be-chinese",
 "http://www.theguardian.com/commentisfree/2016/mar/28/hillary-clinton-honest-transparency-jill-abramson",
 "http://reactionwheel.net/2015/10/the-deployment-age.html",
 "http://www.theguardian.com/sport/2016/mar/28/fight-fans-salford-red-devils-rugby-league-huddersfield",
 "http://www.theguardian.com/football/2016/mar/28/daniel-sturridge-england-roy-hodgson-holland",
 "http://www.theguardian.com/sport/2016/mar/28/widnes-st-helens-super-league-match-report",
 "http://www.theguardian.com/sport/2016/mar/28/wakefield-leeds-rhinos-super-league-warrington-hull-fc-rugby-league",
 "http://www.theguardian.com/sport/2016/feb/27/catalans-dragons-leeds-rhinos-super-league-match-report",
 "http://fivethirtyeight.com/features/shut-up-about-harvard/",
 "http://www.bizjournals.com/sanfrancisco/blog/2014/04/slack-42-million-funding-round-stewart-butterfield.html",
 "https://www.newswhip.com/2015/05/how-paywalls-affect-social-media-success/#Izv6G4J4AWMZtWRS.97",
 "https://www.newswhip.com/",
 "http://a16z.com/2016/03/07/all-about-network-effects/",
 "http://www.harvard.edu/president/speech/2016/to-be-speaker-words-and-doer-deeds-literature-and-leadership",
 "http://www.thecrimson.com/article/2016/3/22/Thank-God-For-Trump/",
 "http://www.wsj.com/articles/SB10001424053111903480904576512250915629460",
 "https://www.facebook.com/SarahSilverman/videos/1094429410607151/?fref=nf",
 "http://themacro.com/articles/2016/01/minimum-viable-product-process/",
 "https://www.youtube.com/watch?v=aCUbvOwwfWM",
 "http://www.bigfastblog.com/quoras-technology-examined",
 "https://mattermark.com/first-official-company-rankings-update/",
 "https://www.farnamstreetblog.com/2016/03/prolific-mr-asimov/",
 "https://gorails.com/forum/advice-on-building-a-reports-feature",
 "https://vimeo.com/92332676",
 "https://www.facebook.com/Vox/videos/499116863609254/",
 "https://paulromer.net/mathiness/",
 "https://robots.thoughtbot.com/segment-io-and-ruby"]

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
end

def pick_comment
  ["thought you'd like this",
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
    "you are a genius"].sample
end

def pick_reply
  ["yeh this is really interesting",
  "interesting, thanks!",
  "robot's be the death of us",
  "i know",
  "thanks i was thinking about this recently...",
  "Yes I think this is totally valid. Really good article, thanks for sharing!",
  "Thanks for sharing :)",
  "This is like totally spot on. Thanks!"].sample
end

def pick_first_name
  ["Alex",
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
  "Adrienne"].sample
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

def coin_flip
  [true, false].sample
end

def pick_user(except = nil)
  User.where.not(id: except).sample
end

def pick_slyp(except = nil)
  Slyp.where.not(id: except).sample
end

def reslyp(sender, recipient = pick_user)
  user_slyp = sender.user_slyps.find_or_create_by({ :slyp_id => pick_slyp.id })
  Reslyp.without_callback(:create, :after, :notify) do
    reslyp = user_slyp.send_slyp(recipient.email, pick_comment)
    if coin_flip
      begin
        reslyp.replies.create({
          :sender_id => reslyp.recipient_id,
          :text => reply_text
          })
      rescue
        puts "#################################### PROBLEM TRYING TO CREATE REPLY ####################################"
      end
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

@alice, @bob = create_alice_and_bob
create_example_users
seed_slyps
generate_bulk_reslyps_and_replies
