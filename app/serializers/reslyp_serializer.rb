class ReslypUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :image
end

class ReslypSerializer < ActiveModel::Serializer
  attributes :id, :sender, :recipient, :comment, :created_at, :reply_count,
             :unseen_replies
  belongs_to :sender, serializer: ReslypUserSerializer
  belongs_to :recipient, serializer: ReslypUserSerializer
end
