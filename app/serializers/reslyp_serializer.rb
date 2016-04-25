class ReslypUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email
end

class ReslypSerializer < ActiveModel::Serializer
  attributes :id, :sender, :recipient, :comment, :created_at
  belongs_to :sender, serializer: ReslypUserSerializer
  belongs_to :recipient, serializer: ReslypUserSerializer
end
