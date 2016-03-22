class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = Slyp.includes(:user_slyps).find(user_slyp.slyp_id)
  end

  def reslyps
    user_slyp.reslyps.where({ :sender => false })
  end

  def reslyps_count
    @slyp.user_slyps.length
  end

  def friends_count
    user_slyp.reslyps.length
  end

  def display_url
    display_url = @slyp.display_url
    invalid = (display_url.nil? or !%w[.jpg .jpeg .png .gif].any?{ |ext| display_url.include?(ext) })
    invalid ? "/assets/blank-image.png": display_url
  end
end
