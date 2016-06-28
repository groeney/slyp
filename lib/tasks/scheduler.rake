desc "Notifies users of unseen activity on user_slyps"
task activity_notifications: :environment do
  User.with_activity.each do |user|
    if Time.now.saturday? && user.notify_activity
      UserMailer.activity(user).deliver_later
    end
  end
end
