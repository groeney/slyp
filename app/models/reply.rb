class Reply < ActiveRecord::Base
  belongs_to :reslyp
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id
  alias_attribute :user, :sender

  def self.authorized_find(user, id)
    reply = Reply.find(id)
    reply if reply.sender == user
  end
end
