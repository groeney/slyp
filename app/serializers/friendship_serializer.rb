class FriendshipSerializer < ActiveModel::Serializer
  attributes :id, :friend_id, :email, :display_name
end
