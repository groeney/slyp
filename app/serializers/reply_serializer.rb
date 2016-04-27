class ReplyUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email
end


class ReplySerializer < ActiveModel::Serializer
  attributes :id, :text, :sender, :created_at
  belongs_to :sender, serializer: ReplyUserSerializer
end