class PrimaryUserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, :email, :display_name, :notify_reslyp,
           :notify_activity, :cc_on_reslyp_email_contact, :weekly_summary,
           :searchable, :send_reslyp_email_from, to: :user

  def initialize(user)
    @user = user
  end

  def friends
    user.friends.sort do |a, b|
      Friendship.total_reslyps(user, b) <=> Friendship.total_reslyps(user, a)
    end
  end
end
