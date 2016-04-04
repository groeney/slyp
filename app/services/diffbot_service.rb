require "diffbot"
module DiffbotService
  def self.fetch(url)
    @url = url
    client = Rails.application.config.diffbot_client
    @response = client.analyze.get(url)
    if !valid_response
      # @response = client.article.get(url)
      # Inject job into delayed jobs and fallback to using article api
      return {:url => @url} if @response[:errorCode] < 500
      return {} if @response[:errorCode] >= 500
    end
    parse_response
  end

  private

  def self.parse_response
    case @response[:type]
    when "other"
      parsed_response = parse_other
    when "article"
      parsed_response = parse_article
    when "video"
      parsed_response = parse_video
    when "product"
      parsed_response = parse_product
    when "image"
      parsed_response = parse_image
    when "discussion"
      parsed_response = parse_discussion
    else
      parsed_response = parse_other
    end
  end

  def self.valid_response
    !@response.try(:error)
  end

  def self.parse_other
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:text] = get_text
    return slyp
  end

  def self.parse_article
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:author] = get_author
    slyp[:date] = get_date
    slyp[:display_url] = get_display_url
    slyp[:icon] = get_icon
    slyp[:site_name] = get_site_name
    slyp[:text] = get_text
    slyp[:word_count] = slyp.try(:[], :text).try(:split).try(:length)
    slyp[:duration] = slyp.try(:[], :word_count).try(:/, 5) # 300w/min in sec
    slyp[:html] = get_html
    return slyp
  end

  def self.parse_video
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:author] = get_author
    slyp[:date] = get_date
    slyp[:display_url] = get_display_url
    slyp[:text] = get_text
    slyp[:duration] = get_duration
    slyp[:html] = get_html
    return slyp
  end

  def self.parse_product
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:display_url] = get_display_url
    slyp[:text] = get_text
    slyp[:word_count] = slyp[:text].try(:split).try(:length)
    slyp[:duration] = slyp[:word_count].try(:/, 5)
    slyp[:html] = get_html
    return slyp
  end

  def self.parse_image
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:display_url] = get_display_url
    return slyp
  end

  def self.parse_discussion
    slyp = {}
    slyp[:url] = get_url
    slyp[:slyp_type] = get_type
    slyp[:title] = get_title
    slyp[:human_lang] = get_human_lang
    slyp[:author] = get_author
    return slyp
  end

  def self.get_url
    @response[:request].try(:[], :resolvedPageUrl) ||
     @response[:request].try(:[], :pageUrl) || @url
  end

  def self.get_type
    @response[:type]
  end

  def self.get_title
    @response[:title]
  end

  def self.get_human_lang
    @response[:humanLanguage]
  end

  def self.get_author
    inner_response = get_inner_response
    postslyp = inner_response.try(:[], :posts) || []
    inner_post = postslyp.try(:first) || {}
    inner_response.try(:[], :author) || inner_post.try(:[], :author) || ""
  end

  def self.get_date
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response.try(:[], :date) || inner_post.try(:[], :date)
  end

  def self.get_display_url
    inner_response = get_inner_response
    images = inner_response.try(:[], :images) || []
    image = images.try(:first) || {}
    possibilities = [image.try(:[], :url),
    image.try(:[], :link), inner_response.try(:[], :embedUrl), inner_response.try(:[], :anchorUrl), @response[:icon]]
    possibilities.find { |possibility| !(possibility.nil? or !%w[data:image .jpg .jpeg .png .gif .ico].any?{ |ext| possibility.include?(ext) })}
  end

  def self.get_icon
    inner_response = get_inner_response
    inner_response.try(:[], :icon)
  end

  def self.get_site_name
    inner_response = get_inner_response
    inner_response.try(:[], :siteName)
  end

  def self.get_text
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response.try(:[], :text) || inner_post.try(:[], :text) || ""
  end

  def self.get_duration
    inner_response = get_inner_response
    inner_response.try(:[], :duration)
  end

  def self.get_html
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
end
