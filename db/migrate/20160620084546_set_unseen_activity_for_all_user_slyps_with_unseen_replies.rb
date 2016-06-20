class SetUnseenActivityForAllUserSlypsWithUnseenReplies < ActiveRecord::Migration
  def change
    UserSlyp.find_each do |user_slyp|
      if user_slyp.unseen_replies > 0
        user_slyp.update(unseen_activity: true)
      end
    end
  end
end
