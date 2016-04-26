class CommentPresenter < BasePresenter
  delegate :id, :comment, :sender, :created_at, to: :comment
end