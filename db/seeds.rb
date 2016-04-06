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

 @overflow_urls = ["http://www.bloomberg.com/features/2016-how-to-hack-an-election/",
 "http://www.nytimes.com/2015/06/23/opinion/when-an-apology-is-anything-but.html?mabReward=A4&moduleDetail=recommendations-2&action=click&contentCollection=U.S.&region=Footer&module=WhatsNext&version=WhatsNext&contentID=WhatsNext&configSection=article&isLoggedIn=false&src=recg&pgtype=article&_r=0",
 "http://paulromer.net/mathiness/",
 "http://www.barrelny.com/blog/taking-control-of-imageloading/",
 "https://medium.com/@dhh/rails-5-action-cable-demo-8bba4ccfc55e#.f45ezr1v2",
 "http://www.sitepoint.com/action-cable-and-websockets-an-in-depth-tutorial/",
 "https://news.ycombinator.com/item?id=9419601",
 "https://blog.engineyard.com/2015/a-look-at-rails-5",
 "https://m.signalvnoise.com/sleep-deprivation-is-not-a-badge-of-honor-f24fbff47a75#.rt0ao89zj",
 "https://www.youtube.com/watch?v=n0WUjGkDFS0",
 "http://boingboing.net/2015/05/11/the-only-technique-to-learn-so.html",
 "http://www.wired.com/2015/04/hire-like-google/",
 "http://www.vanityfair.com/culture/2015/08/tinder-hook-up-culture-end-of-dating",
 "https://www.quarterlyessay.com/qe/61/australia-between-recession-and-renewal/1424",
 "https://www.thesaturdaypaper.com.au/news/politics/2016/04/02/the-taxpayers-billions-spent-government-advertising/14595156003073",
 "http://insider.foxnews.com/2016/03/31/harvard-student-rise-safe-spaces-campus-culture-sensitivity",
 "http://stackoverflow.com/questions/2862590/how-to-replace-master-branch-in-git-entirely-from-another-branch",
 "http://www.wheelercentre.com/events/whistleblowers",
 "https://en.wikipedia.org/wiki/Liang_Cheng",
 "http://techcrunch.com/2016/01/05/facebook-messenger-bots/",
 "https://mixpanel.com/blog/2016/03/30/this-is-the-difference-between-statistics-and-data-science",
 "http://www.slate.com/articles/technology/cover_story/2016/01/how_facebook_s_news_feed_algorithm_works.html",
 "https://mixpanel.com/blog/2016/03/31/data-loss-incident-update",
 "http://www.theaustralian.com.au/business/economics/surging-australian-dollar-puts-squeeze-on-exporters/news-story/f40f7f3f3e8e10ed437cae62b458d7ed",
 "https://www.quora.com/What-are-the-biggest-companies-that-no-ones-ever-heard-of",
 "https://www.youtube.com/watch?v=CBYhVcO4WgI&list=PL11qn6zM2Y3bMZdChxEqHKaCaKUjwItGL",
 "https://www.youtube.com/watch?v=hUl27Qj9cEM&feature=youtu.be",
 "http://www.theguardian.com/news/2016/apr/03/panama-papers-money-hidden-offshore",
 "https://robots.thoughtbot.com/how-to-back-up-a-heroku-production-database-to-staging",
 "https://www.youtube.com/watch?v=hykoKDl1AtE#t=30",
 "https://www.youtube.com/watch?v=Ri0qiAita4s",
 "https://swiftkey.com/en/united-states-emoji",
 "https://medium.com/slack-developer-blog/everything-you-ever-wanted-to-know-about-unfurling-but-were-afraid-to-ask-or-how-to-make-your-e64b4bb9254#.a69oxphgz",
 "http://www.datadan.io/containerized-data-science-and-engineering-part-2-dockerized-data-science/",
 "http://www.nytimes.com/2016/03/27/books/review/sext-and-the-single-girl.html?hp&action=click&pgtype=Homepage&clickSource=story-heading&module=second-column-region&region=top-news&WT.nav=top-news&_r=3&mtrref=undefined&gwh=C553BAE4C761D390E0C006B1B22C5A50&gwt=pay",
 "https://blog.greens.org.nz/2016/04/04/milk-and-coal-in-southland/",
 "http://stackoverflow.com/questions/22619529/using-twilio-number-as-a-proxy-for-sms-communication",
 "https://www.kickstarter.com/projects/248983394/ossic-x-the-first-3d-audio-headphones-calibrated-t",
 "http://www.nytimes.com/2016/04/10/education/edlife/teaching-men-to-be-emotionally-honest.html",
 "https://www.youtube.com/watch?v=LVa4ERqz97o"]

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
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
  100.times do |n|
    first_name = @first_names[n % @first_names.length]
    email = "#{first_name}_#{n}@example.com"
    user = User.find_or_create_by({:email => email.downcase, :first_name => first_name, :last_name => "Example #{n}"})
    user.password = "password" if user.encrypted_password.blank?
    user.save!
  end
end

# Seed db with slyps
def seed_slyps()
  VCR.use_cassette("slyp_seeds", :record => :all) do
    @slyp_seed_urls.each do |url|
      Slyp.fetch(url)
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
    user_1_slyp.send_slyp(@alice.email,comment)
    user_1_slyp.send_slyp(@bob.email,comment)

    user_2_index = Random.rand(num_users)
    user_2 = users[user_2_index]

    # Generate reslyps for user_1 and user_2
    user_1_slyp.send_slyp(user_2.email, comment)

    # Generate reslyps from alice or bob
    alice_user_slyp.send_slyp(user_2.email, comment)
    bob_user_slyp.send_slyp(user_2.email, comment)
  end
end

@alice, @bob = create_alice_and_bob()
create_example_users()
seed_slyps()
generate_bulk_reslyps()


