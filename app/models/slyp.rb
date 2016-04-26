require "active_record/diff"
class Slyp < ActiveRecord::Base
  include ActiveRecord::Diff

  has_many :user_slyps, :dependent => :destroy
  has_many :users, through: :user_slyps

  validates :url, :url => true, presence: true

  def complete?
    !self.try(:url).nil? and !self.try(:title).nil?
  end

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
        if diff_values.min.size.fdiv(diff_values.max.size) < 0.95
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
    slyp = Slyp.find_by({:url => url})
    slyp.try(:complete?) ? slyp : nil
  end

  def self.create_from_url(url)
    parsed_response = InstaparserService.fetch(url)
    Slyp.find_match_or_create_by(parsed_response)
  end

  def self.find_match_or_create_by(parsed_response)
    url_match = Slyp.find_by({:url => parsed_response[:url]})
    if url_match.try(:complete?)
      return url_match
    elsif url_match.try(:valid?)
      url_match.update(parsed_response)
      return url_match
    end

    title_match = Slyp.find_by({:title => parsed_response[:title]})
    candidate = Slyp.create(parsed_response)

    unless title_match.try(:title).nil?
      if title_match.try(:match, candidate)
        title_match.update_url(candidate.url)
        candidate.destroy()
        return title_match
      end
    end
    return candidate
  end
end
