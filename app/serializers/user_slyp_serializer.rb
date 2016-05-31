class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id, :url,
             :archived, :favourite, :deleted, :duration, :friends, :slyp_type,
             :html, :total_favourites, :total_reslyps, :latest_conversation,
             :description, :unseen, :unseen_activity, :unseen_replies
end
