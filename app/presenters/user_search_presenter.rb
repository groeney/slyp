class UserSearchPresenter < BasePresenter
  attr_accessor :user
  delegate :email, to: :user

  def initialize(user)
    @user = user
  end

  def display_name
    user.invitation_pending? ? user.email + " (pending)" : [user.first_name, user.last_name].reject(&:empty?).join(" ")
  end
end