class FriendSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :image
end

class FriendshipSerializer < ActiveModel::Serializer
  attributes :id, :friend
  belongs_to :friend, serializer: FriendSerializer
end
