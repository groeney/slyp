class Reslyp < ActiveRecord::Base
  belongs_to :user_slyp
  belongs_to :user
  validates_uniqueness_of :user_slyp_id, :scope => :user_id

  delegate :slyp, to: :user_slyp

  after_create :manage_friendship

  def receive_reslyp(comment) # TODO: argh, need to work this out.
    slyp_id = self.slyp_id
    to_user_slyp = self.user.user_slyps.find_by({:slyp_id => slyp_id})
    to_user_slyp.reslyps.find_or_create_by({
      :user_id => self.user_slyp.user_id,
      :sender => false,
      :comment => comment,
      :slyp_id => slyp_id
      })
  end

  def sibling
    user = self.user_slyp.user
    friend_user_slyp = self.user.user_slyps.find_by({:slyp_id => self.slyp_id})
    sibling = friend_user_slyp.reslyps.find_by({:user_id => user.id})
    return sibling.id == self.id ? nil : sibling
  end

  protected

  def manage_friendship
    self.user_slyp.user.friendships.create({
      :friend_id => self.user.id
      })

    self.user.friendships.create({
      :friend_id => self.user_slyp.user.id
      })
  end
end
