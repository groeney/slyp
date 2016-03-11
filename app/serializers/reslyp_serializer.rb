class ReslypSerializer < ActiveModel::Serializer
  attributes :id, :sender, :user
  belongs_to :user

  class UserSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email
  end
end
