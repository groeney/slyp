class UserSearchPresenter < BasePresenter
  attr_accessor :user
  delegate :display_name, :email, to: :user

  def initialize(user)
    @user = user
  end
end