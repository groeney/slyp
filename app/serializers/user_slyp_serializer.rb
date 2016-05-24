class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id, :url,
             :archived, :favourite, :deleted, :duration, :friends, :slyp_type,
             :unseen, :unseen_activity, :total_reslyps, :latest_comment, :html,
             :total_favourites
end
