require "erb"
include ERB::Util

module InstaparserService
  def self.fetch(url)
    encoded_url = url_encode(url)
    req_url = format_url(encoded_url)
    begin
      @response = JSON.parse(URI.parse(req_url).read)
    rescue OpenURI::HTTPError => error
      err_msg = error.message
      Rails.logger.info "Failed to unfurl #{url}. #{err_msg}"
      if ENV.fetch("RAILS_ENV", "") == "test" and err_msg.include? "429"
        puts "######### INSTAPARSER API ERROR ###########" +
          "Error: #{err_msg}" +
          "Check spec/vcr/InstaparserService/* for bad cached requests."
      end
      return { :url => url }
    end
    parse_response
  end

  private

  def self.format_url(slyp_url)
    endpoint = "https://www.instaparser.com/api/1/article"
    params = {
      :api_key => "api_key=#{ENV["INSTAPARSER_TOKEN"]}",
      :url     => "url=#{slyp_url}"
    }
    return endpoint + "?" + params[:api_key] + "&" + params[:url]
  end

  def self.parse_response
    slyp_hash = {}
    slyp_hash[:url] = get_url
    slyp_hash[:title] = get_title
    slyp_hash[:author] = get_author
    slyp_hash[:date] = get_date
    slyp_hash[:site_name] = get_site_name
    slyp_hash[:favicon] = slyp_hash[:site_name] ?
      "http://www.google.com/s2/favicons?domain=#{slyp_hash[:site_name]}" : nil
    slyp_hash[:display_url] = get_display_url
    slyp_hash[:html] = get_html
    slyp_hash[:text] = Sanitize.fragment(slyp_hash[:html]).strip
    slyp_hash[:word_count] = slyp_hash[:text].split.size
    slyp_hash[:duration] = slyp_hash[:word_count].try(:/, 5)
    slyp_hash[:description] = get_description
    slyp_hash[:slyp_type] = get_slyp_type(slyp_hash)
    return slyp_hash
  end

  def self.get_url
    @response["url"]
  end

  def self.get_title
    @response["title"]
  end

  def self.get_author
    @response["author"]
  end

  def self.get_date
    @response["date"] ? Time.at(@response["date"]).to_datetime : nil
  end

  def self.get_display_url
    @response["thumbnail"] || @response["images"].first
  end

  def self.get_site_name
    @response["site_name"]
  end

  def self.get_word_count
    @response["words"]
  end

  def self.get_html
    @response["html"]
  end

  def self.get_description
    @response["description"]
  end

  def self.get_slyp_type(slyp_hash)
    (slyp_hash[:html].include?("video_frame") and slyp_hash[:word_count] <= 300) ?
      "video" : "article"
  end
end
