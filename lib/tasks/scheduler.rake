desc "Notifies users of unseen activity on user_slyps"
task activity_notifications: :environment do
  User.with_activity.each do |user|
    if Time.now.saturday? && user.notify_activity
      UserMailer.activity(user).deliver_later
    end
  end
end

desc "Outreach email #1 for activated users"
task activated_outreach_one: :environment do
  User.where("activated_at >= ?", 1.day.ago).each do |user|
    user.send_activated_outreach_one if user.active?
  end
end

desc "Outreach email #1 for invited users"
task invited_outreach_one: :environment do
  User.where("invitation_sent_at <= ?", 3.day.ago).each do |user|
    User.invite!({ email:user.email }, user.invited_by) if user.invited?
  end
end


