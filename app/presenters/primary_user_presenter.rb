class PrimaryUserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, :email, :display_name, :notify_reslyp,
           :notify_activity, :cc_on_reslyp_email_contact, :weekly_summary,
           :searchable, :send_reslyp_email_from, :referral_link,
           :send_new_friend_notification, to: :user

  def initialize(user)
    @user = user
  end
end
