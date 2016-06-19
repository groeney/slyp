class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type,
           :description, :image, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, :friends,
           :total_favourites, :latest_conversation, :total_reslyps,
           :unseen, :unseen_activity, :unseen_replies, to: :user_slyp

  def initialize(user_slyp, show_html = false)
    @user_slyp = user_slyp
    @slyp = user_slyp.slyp
    @show_html = show_html
  end

  def html
    @show_html ? slyp.html : nil
  end
end
