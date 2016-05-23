class ReplyPresenter < BasePresenter
  attr_accessor :reply
  delegate :id, :text, :sender, :created_at, :updated_at, to: :reply
  def initialize(reply)
    @reply = reply
  end
end
