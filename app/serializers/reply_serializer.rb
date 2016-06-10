class ReplyUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :image
end

class ReplySerializer < ActiveModel::Serializer
  attributes :id, :text, :sender, :created_at, :updated_at, :sender_id
  belongs_to :sender, serializer: ReplyUserSerializer
end
