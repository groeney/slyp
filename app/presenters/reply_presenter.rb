class ReplyPresenter < BasePresenter
  delegate :id, :reply, :sender, :created_at, to: :reply
end