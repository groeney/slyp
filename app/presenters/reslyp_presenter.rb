class ReslypPresenter < BasePresenter
  attr_accessor :reslyp
  delegate :id, :sender, :recipient, :comment, :created_at, :reply_count,
           to: :reslyp

  def initialize(reslyp, user)
    @reslyp = reslyp
    @user = user
  end

  def unseen_replies
    reslyp.unseen_replies(@user.id)
  end
end
