desc "Notifies users of unseen activity on user_slyps"
task activity_notifications: :environment do
  User.with_activity.each do |user|
    UserMailer.activity(user).deliver_later
  end
end
