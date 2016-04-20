require "active_record/diff"
class Slyp < ActiveRecord::Base
  include ActiveRecord::Diff

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

  def describe_type
    return case self.slyp_type
    when "video"
      "a video"
    when "article"
      "an article"
    else
      "a slyp"
    end
  end

  def self.fetch(url)
    slyp = fetch_from_db(url) || create_from_url(url)
  end

  def match(candidate)
    diff = self.diff(candidate).except(:created_at, :updated_at)
    case diff.keys
    when [:url], []
      return true
    else
      (diff.keys - [:url]).each do |key| # Perform rudimentary comparison between values
        diff_values = diff[key]
        if diff_values.min.size.fdiv(diff_values.max.size) < 0.99
          return false
        end
      end
      return true
    end
  end

  def update_url(candidate_url)
    if candidate_url.length < self.url.length
      self.update({:url => candidate_url})
    end
  end

  private

  def self.fetch_from_db(url)
    Slyp.find_by(url: url)
  end

  def self.create_from_url(url)
    parsed_response = InstaparserService.fetch(url)
    Slyp.find_match_or_create_by(parsed_response)
  end

  def self.find_match_or_create_by(parsed_response)
    url_match = Slyp.find_by({:url => parsed_response[:url]})
    if url_match.try(:valid?)
      return url_match
    end

    title_match = Slyp.find_by({:title => parsed_response[:title]})
    candidate = Slyp.create(parsed_response)
    if title_match.try(:match, candidate)
      title_match.update_url(candidate.url)
      candidate.destroy()
      return title_match
    end
    return candidate
  end
end
