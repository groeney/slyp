class CommentUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email
end


class CommentSerializer < ActiveModel::Serializer
  attributes :id, :comment, :sender, :created_at
  belongs_to :sender, serializer: CommentUserSerializer
end