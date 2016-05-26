class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :full_name, :display_name
end
