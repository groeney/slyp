class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id, :url,
  :archived, :favourite, :deleted, :duration, :friends_count, :slyp_type, :html,
  :unseen, :unseen_activity, :total_reslyps, :comments
end
