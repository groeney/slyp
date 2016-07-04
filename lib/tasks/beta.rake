namespace :beta do
  desc "Invites the next batch of users on waitlist"
  task invite_batch: :environment do
    batch_size = 10
    invitees = User.where(status: 1).limit(batch_size)
    invitees.each(&:invite!)
  end

  desc "Invite particular user from waitlist"
  task :invite_email, [:email] => :environment do |_t, args|
    invitee = User.find_by(email: args[:email])
    if invitee.nil?
      puts "#{args[:email]} not found. Inviting new user."
      User.invite!({ email: args[:email] }, User.support_user)
    elsif invitee.active?
      puts "User already active!"
    else
      invitee.invite!
    end
  end
end
