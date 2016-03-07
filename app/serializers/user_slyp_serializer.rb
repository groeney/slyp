class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author,
    :duration, :archived, :favourite, :deleted, :url, :friend_reslyps, :reslyps
end
