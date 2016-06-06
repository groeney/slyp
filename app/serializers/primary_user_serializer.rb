class PrimaryUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :full_name, :display_name,
             :friends, :notify_friend_joined, :notify_replies, :notify_reslyp,
             :weekly_summary
end
