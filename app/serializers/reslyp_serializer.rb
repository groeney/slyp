class ReslypUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :friends
end

class ReslypSerializer < ActiveModel::Serializer
  attributes :id, :sender, :user, :comment, :created_at
  belongs_to :user, serializer: ReslypUserSerializer
end
