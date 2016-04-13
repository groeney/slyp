class Slyp < ActiveRecord::Base
  has_many :user_slyps, :dependent => :destroy
  has_many :users, through: :user_slyps

  validates :url, :url => true, presence: true

  def slyp_type
    unless !self.html
      return (self.html.include?("video_frame") and self.word_count <= 300) ?
        "video" : "article"
    end
    return "other"
  end

  def self.fetch(url)
    slyp = fetch_from_db(url) || create_from_url(url)
  end

  private

  def self.fetch_from_db(url)
    Slyp.find_by(url: url)
  end

  def self.create_from_url(url)
    parsed_response = InstaparserService.fetch(url)
    slyp = Slyp.find_by({:url => parsed_response[:url]})
    if slyp
      return slyp
    else
      return Slyp.create(parsed_response)
    end
  end
end
