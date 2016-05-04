class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type, :html, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, :friends,
    :unseen, :unseen_activity, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = Slyp.find(@user_slyp.slyp_id)
  end

  def display_url
    display_url = @slyp.display_url
    invalid = (display_url.nil? or !%w[data:image .jpg .jpeg .png .gif .ico].any?{ |ext| display_url.include?(ext) })
    invalid ? "/assets/logo.png": display_url
  end

  def total_reslyps
    Reslyp.where(slyp_id: user_slyp.slyp_id).length
  end

  def latest_comment
    reslyp = user_slyp.reslyps.last
    text = reslyp.try(:comment) || ""
    email = reslyp.try(:sender).try(:email) || ""
    { :text => text, :email => email }
  end
end
