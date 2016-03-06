class SlypSerializer < ActiveModel::Serializer
  attributes :id, :display_url, :title, :site_name, :author
end
