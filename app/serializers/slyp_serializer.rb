class SlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author, :duration, :archived, :favourite, :deleted
end
