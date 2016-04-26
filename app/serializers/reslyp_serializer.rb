class ReslypUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email
end

class ReslypSerializer < ActiveModel::Serializer
  attributes :id, :sender, :comment, :replies, :created_at
  belongs_to :sender, serializer: ReslypUserSerializer
  has_many :replies, each_serializer: ReplySerializer
end
