class Reply < ActiveRecord::Base
  belongs_to :reslyp
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id
  alias_attribute :user, :sender

  validates_presence_of :reslyp
  validates_presence_of :sender
  validates_presence_of :text

  validate do |reply|
    unless reply.sender == reply.reslyp.sender || reply.sender == reply.reslyp.recipient
      errors.add(:base, "Sender is not on parent reslyp.")
    end
  end

  def self.authorized_find(user, id)
    reply = Reply.find(id)
    if reply.sender == user
      reply
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
