class UserSearchSerializer < ActiveModel::Serializer
  attributes :id, :display_name, :email, :image
end
