class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :duration, :display_url, :title, :site_name, :author, :url, to: :slyp
  delegate :id, :archived, :favourite, :deleted, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = user_slyp.slyp
  end

  def friend_reslyps
    user_slyp.reslyps
  end

  def reslyps
    @slyp.user_slyps.length
  end
end
