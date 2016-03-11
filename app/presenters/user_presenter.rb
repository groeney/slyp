class UserPresenter < BasePresenter
  attr_accessor :user
  delegate :id, :first_name, :last_name, to: :user

  def initialize(user)
    @user = user
  end
end