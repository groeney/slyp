# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
slyp_seed_urls = [
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
  "http://www.newyorker.com/magazine/2015/05/18/lighting-the-brain"
]

slyp_seed_urls.each do |url|
  Slyp.fetch({:url => url})
end
