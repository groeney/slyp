class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :image
end

class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :image, :title, :site_name, :author, :slyp_id, :url,
             :archived, :favourite, :deleted, :duration, :slyp_type,
             :html, :total_favourites, :total_reslyps, :latest_conversation,
             :description, :unseen, :unseen_activity, :unseen_replies
  has_many :friends, each_serializer: UserSerializer
end
