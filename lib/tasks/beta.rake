namespace :beta do
  desc "Invites the next batch of beta request users on waitlist"
  task invite_batch: :environment do
    batch_size = 10
    invitees = BetaRequest.where(invited: false, signed_up: false)
                          .first(batch_size)
    invitees.each do |invitee|
      invitee.update(invited: true)
      UserMailer.beta_invitation(invitee).deliver_now if invitee.save!
    end
  end

  desc "Invite particular user from waitlist"
  task :invite_user, [:email] => :environment do |_t, args|
    invitee = BetaRequest.find_by(email: args[:email])
    if invitee.nil?
      puts "Email #{args[:email]} not on waitlist."
    else
      invitee.update(invited: true)
      UserMailer.beta_invitation(invitee).deliver_now if invitee.save!
    end
  end
end
