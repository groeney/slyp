require "diffbot"
module DiffbotService
  def self.fetch(url)
    @url = url
    client = Rails.application.config.diffbot_client
    @response = client.article.get(url)
    if !valid_response
      # @response = client.article.get(url)
      # Inject job into delayed jobs and fallback to using article api
      return {:url => @url} if @response[:errorCode] < 500
      return {} if @response[:errorCode] >= 500
    end
    parse_response
  end

  private

  def self.valid_response
    !@response.try(:error)
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
    slyp_hash[:text] = fetch_text
    slyp_hash[:word_count] = slyp_hash[:text].split.size
    slyp_hash[:duration] = slyp_hash[:word_count].try(:/, 5)
    slyp_hash[:slyp_type] = fetch_slyp_type(slyp_hash)
    slyp_hash
  end

  def self.fetch_url
    @response[:request].try(:[], :resolvedPageUrl) ||
     @response[:request].try(:[], :pageUrl) || @url
  end

  def self.fetch_type
    @response[:type]
  end

  def self.fetch_title
    @response[:title]
  end

  def self.fetch_author
    inner_response = get_inner_response
    post_slyp = inner_response.try(:[], :posts) || []
    inner_post = post_slyp.try(:first) || {}
    inner_response.try(:[], :author) || inner_post.try(:[], :author) || ""
  end

  def self.fetch_date
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response.try(:[], :date) || inner_post.try(:[], :date)
  end

  def self.fetch_display_url
    inner_response = get_inner_response
    images = inner_response.try(:[], :images) || []
    image = images.try(:first) || {}
    possibilities = [image.try(:[], :url),
    image.try(:[], :link), inner_response.try(:[], :embedUrl), inner_response.try(:[], :anchorUrl), @response[:icon]]
    possibilities.find { |possibility| !(possibility.nil? or !%w[data:image .jpg .jpeg .png .gif .ico].any?{ |ext| possibility.include?(ext) })}
  end

  def self.fetch_site_name
    inner_response = get_inner_response
    inner_response.try(:[], :siteName)
  end

  def self.fetch_text
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response.try(:[], :text) || inner_post.try(:[], :text) || Sanitize.fragment(fetch_html).strip || ""
  end

  def self.fetch_html
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response.try(:[], :html) || inner_post.try(:[], :html) || ""
  end

  def self.get_inner_response
    @response[:objects].try(:first) || @response
  end

  def self.get_inner_post
    inner_response = get_inner_response
    posts = inner_response.try(:[], :posts) || []
    inner_post = posts.try(:first) || {}
  end

  def self.fetch_slyp_type(slyp_hash)
    if slyp_hash[:html].include?("video_frame") && slyp_hash[:word_count] <= 300
      "video"
    else
      "article"
    end
  end
end
