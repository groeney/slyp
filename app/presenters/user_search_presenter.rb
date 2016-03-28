class UserSearchPresenter < BasePresenter
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def name
    [user.first_name, user.last_name].reject(&:empty?).join(" ")
  end

  def value
    user.email
  end

  def description
    user.email
  end
end