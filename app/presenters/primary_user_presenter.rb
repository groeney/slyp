class PrimaryUserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, :email, :display_name, to: :user

  def initialize(user)
    @user = user
  end

  def full_name
    [user.first_name, user.last_name].reject(&:empty?).join(" ")
  end

  def friends
    user.friends.sort { |a, b| b.slyps_exchanged_with(user.id) <=> a.slyps_exchanged_with(user.id)  }
  end
end
