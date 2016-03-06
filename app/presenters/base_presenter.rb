# Provides basic support for using presenters with ActiveModel serializers.
class BasePresenter
  extend ActiveModel::Naming

  alias read_attribute_for_serialization send
end
