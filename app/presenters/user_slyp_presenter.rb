class UserSlypPresenter < BasePresenter
  attr_accessor :user_slyp, :slyp

  delegate :title, :duration, :site_name, :author, :url, :slyp_type, :html, to: :slyp
  delegate :id, :archived, :favourite, :deleted, :slyp_id, to: :user_slyp

  def initialize(user_slyp)
    @user_slyp = user_slyp
    @slyp = Slyp.find(@user_slyp.slyp_id)
  end

  def reslyps
    user_slyp.reslyps.where({ :sender => false })
  end

  def friends
    user_slyp.reslyps.includes(:user).map { |reslyp| {
      :id => reslyp.user.id,
      :email => reslyp.user.email,
      :first_name => reslyp.user.first_name,
      :last_name => reslyp.user.last_name,
      :sender => reslyp.sender
      }
    }
  end

  def total_reslyps
    Reslyp.where({:slyp_id => @slyp.id}).length/2
  end

  def display_url
    display_url = @slyp.display_url
    invalid = (display_url.nil? or !%w[.jpg .jpeg .png .gif .ico].any?{ |ext| display_url.include?(ext) })
    invalid ? "/assets/blank-image.png": display_url
  end
end
