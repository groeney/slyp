class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type,
           :html, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, :friends,
           :unseen, :unseen_activity, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = Slyp.find(@user_slyp.slyp_id)
  end

  def display_url
    display_url = @slyp.display_url
    invalid_exts = %w(data:image .jpg .jpeg .png .gif .ico)
    invalid = (display_url.nil? ||
      !invalid_exts.any? { |ext| display_url.include?(ext) })
    invalid ? "/assets/logo.png" : display_url
  end

  def total_reslyps
    Reslyp.where(slyp_id: user_slyp.slyp_id).length
  end

  def total_favourites
    UserSlyp.where(slyp_id: user_slyp.slyp_id, favourite: true).length
  end

  def latest_conversation
    conversation = [latest_comment, latest_reply].reject(&:nil?)
                                                 .max_by { |el| el.created_at }
    text = conversation.try(:comment) || conversation.try(:text) || ""
    email = conversation.try(:sender).try(:email) || ""
    first_name = conversation.try(:sender).try(:first_name) || ""
    { text: text, email: email, first_name: first_name }
  end

  private

  def latest_comment
    user_slyp.reslyps.last
  end

  def latest_reply
    replies = user_slyp.reslyps.map { |el| el.replies }.flatten
    replies.max_by { |el| el.created_at }
  end
end
