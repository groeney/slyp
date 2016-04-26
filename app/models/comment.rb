class Comment < ActiveRecord::Base
  belongs_to :reslyp
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id
  alias_attribute :user, :sender
end
