class Reslyp < ActiveRecord::Base
  belongs_to :user_slyp
  belongs_to :user

  validates_uniqueness_of :user_slyp_id, :scope => :user_id
  validates_presence_of :user
  validates_presence_of :user_slyp

  delegate :slyp, to: :user_slyp

  after_create :manage_friendship

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
