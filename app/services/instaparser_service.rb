require "erb"
include ERB::Util
require "open-uri"
module InstaparserService
  def self.fetch(url)
    encoded_url = url_encode(url)
    req_url = format_url(encoded_url)
    begin
      @response = JSON.parse(URI.parse(req_url).read)
    rescue OpenURI::HTTPError => error
      Rails.logger.info "Failed to unfurl #{url}: #{error.message}."\
        "Try checking spec/vcr/InstaparserService/* for bad cached requests."
      return { url: url }
    end
    parse_response
  end

  def self.format_url(slyp_url)
    endpoint = "https://www.instaparser.com/api/1/article"
    params = {
      api_key: "api_key=#{ENV['INSTAPARSER_TOKEN']}",
      url: "url=#{slyp_url}"
    }
    endpoint + "?" + params[:api_key] + "&" + params[:url]
  end

  def self.parse_response
    slyp_hash = {}
    slyp_hash[:url] = fetch_url
    slyp_hash[:title] = fetch_title
    slyp_hash[:author] = fetch_author
    slyp_hash[:date] = fetch_date
    slyp_hash[:site_name] = fetch_site_name
    favicon_url = "https://www.google.com/s2/favicons?domain="\
      "#{slyp_hash[:site_name]}"
    slyp_hash[:favicon] = slyp_hash[:site_name] ? favicon_url : nil
    slyp_hash[:display_url] = fetch_display_url
    slyp_hash[:html] = fetch_html
    slyp_hash[:text] = Sanitize.fragment(slyp_hash[:html]).strip
    slyp_hash[:word_count] = slyp_hash[:text].split.size
    slyp_hash[:duration] = slyp_hash[:word_count].try(:/, 5)
    slyp_hash[:description] = fetch_description
    slyp_hash[:slyp_type] = fetch_slyp_type(slyp_hash)
    slyp_hash
  end

  def self.fetch_url
    @response["url"]
  end

  def self.fetch_title
    @response["title"]
  end

  def self.fetch_author
    @response["author"]
  end

  def self.fetch_date
    @response["date"] ? Time.at(@response["date"]).to_datetime : nil
  end

  def self.fetch_display_url
    display_url = @response["thumbnail"] || @response["images"].first
    display_url.gsub("http://", "https://")
  end

  def self.fetch_site_name
    @response["site_name"]
  end

  def self.fetch_word_count
    @response["words"]
  end

  def self.fetch_html
    html = @response["html"]
    html.gsub("iframe src=\"http:", "iframe src=\"https:") unless html.blank?
  end

  def self.fetch_description
    @response["description"]
  end

  def self.fetch_slyp_type(slyp_hash)
    if slyp_hash[:html].include?("video_frame") && slyp_hash[:word_count] <= 300
      "video"
    else
      "article"
    end
  end
end
