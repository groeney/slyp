require "active_record/diff"
class Slyp < ActiveRecord::Base
  include ActiveRecord::Diff

  has_many :user_slyps, dependent: :destroy
  has_many :users, through: :user_slyps

  validates :url, url: true, presence: true

  def complete?
    !url.nil? && !title.nil?
  end

  def slyp_type
    return "other" unless html
    if (html.include? "video_frame") && (word_count <= 300)
      "video"
    else
      "article"
    end
  end

  def describe_type
    case slyp_type
    when "video"
      "a video"
    when "article"
      "an article"
    else
      "a slyp"
    end
  end

  def self.fetch(url)
    fetch_from_db(url) || create_from_url(url)
  end

  def match(candidate)
    diff = self.diff(candidate).except(:created_at, :updated_at)
    case diff.keys
    when [:url], []
      return true
    else
      (diff.keys - [:url]).each do |key| # Rudimentary comparison
        return false if diff[key].min.size.fdiv(diff[key].max.size) < 0.95
      end
      return true
    end
  end

  def update_url(candidate_url)
    update_attribute(:url, candidate_url) if candidate_url.length < url.length
  end

  def image
    invalid_exts = %w(data:image .jpg .jpeg .png .gif .ico)
    invalid = (display_url.nil? ||
      !invalid_exts.any? { |ext| display_url.include?(ext) })
    invalid ? "/assets/logo.png" : display_url
  end

  def display_title
    title || url
  end

  def self.fetch_from_db(url)
    slyp = Slyp.find_by(url: url)
    slyp.try(:complete?) ? slyp : nil
  end

  def self.create_from_url(url)
    Slyp.find_match_or_create_by(raw_attributes(url))
  end

  def raw_attributes(url)
    raw = InstaparserService.fetch(url)
    raw.html.gsub("iframe src=\"http:", "iframe src=\"https:")
    return raw
  end

  def self.find_match_or_create_by(parsed_response)
    url_match = Slyp.find_url_match(parsed_response)
    return url_match if url_match.try(:complete?)
    Slyp.find_title_match_or_use_response(parsed_response)
  end

  def self.find_url_match(parsed_response)
    url_match = Slyp.find_by(url: parsed_response[:url])
    return url_match if url_match.try(:complete?)
    return false unless url_match.try(:valid?)
    url_match.update_attributes(parsed_response)
    url_match
  end

  def self.find_title_match_or_use_response(parsed_response)
    title_match = Slyp.find_by(title: parsed_response[:title])
    candidate = Slyp.create(parsed_response)
    unless title_match.try(:title).nil?
      if title_match.try(:match, candidate)
        title_match.update_url(candidate.url)
        candidate.destroy
        return title_match
      end
    end
    candidate
  end
end
