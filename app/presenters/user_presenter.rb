class UserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, :email, to: :user

  def initialize(user)
    @user = user
  end

  def full_name
    [user.first_name, user.last_name].reject(&:empty?).join(" ")
  end
end
