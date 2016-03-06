require "diffbot"
module DiffbotService
  def self.fetch(url)
    @url = url
    client = Rails.application.config.diffbot_client
    @response = client.analyze.get(url)
    parse_response
  end

  private

  def self.parse_response
    if !valid_response
      return {:url => @url} if @response[:errorCode] < 500
      return {} if @response[:errorCode] >= 500
    end

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
    !@response[:error]
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
    slyp[:word_count] = slyp[:text].split().length
    slyp[:duration] = slyp[:word_count]/5 # 300w/min in sec
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
    slyp[:word_count] = slyp[:text].split().length
    slyp[:duration] = slyp[:word_count]/5
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
    @response[:request][:resolvedPageUrl] || @response[:request][:pageUrl]
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
    postslyp = inner_response[:posts] || []
    inner_post = postslyp[0] || {}
    inner_response[:author] || inner_post[:author] || ""
  end

  def self.get_date
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response[:date] || inner_post[:date]
  end

  def self.get_display_url
    inner_response = get_inner_response
    image = inner_response[:images][0] || {}
    inner_response[:embedUrl] || image[:url] || image[:link] || inner_response[:url] || inner_response[:anchorUrl]
  end

  def self.get_icon
    inner_response = get_inner_response
    inner_response[:icon]
  end

  def self.get_site_name
    inner_response = get_inner_response
    inner_response[:siteName]
  end

  def self.get_text
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response[:text] || inner_post[:text] || ""
  end

  def self.get_duration
    inner_response = get_inner_response
    inner_response[:duration]
  end

  def self.get_html
    inner_response = get_inner_response
    inner_post = get_inner_post
    inner_response[:html] || inner_post[:html] || ""
  end

  def self.get_inner_response
    @response[:objects][0] || {}
  end

  def self.get_inner_post
    inner_response = get_inner_response
    posts = inner_response[:posts] || []
    inner_post = posts[0] || {}
  end
end