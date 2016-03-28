class UserSlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :slyp_id, :url,
  :archived, :favourite, :deleted, :duration, :friends, :total_reslyps,
  :slyp_type
  has_many :reslyps, serializer: ReslypSerializer
end
