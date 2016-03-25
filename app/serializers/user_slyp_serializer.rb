class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id,
  :friends_count, :duration, :archived, :favourite, :deleted, :url,
  :friends, :reslyps_count, :slyp_type
  has_many :reslyps, serializer: ReslypSerializer
end
