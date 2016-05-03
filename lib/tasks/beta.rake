namespace :beta do
  desc "Invites the next batch of beta request users on waitlist"
  task invite_batch: :environment do
    batch_size = 10
    invitees = BetaRequest.where({
      :invited => false,
      :signed_up => false
      }).first(batch_size)
    invitees.each do |invitee|
      invitee.update({:invited => true})
      if invitee.save!
        UserMailer.beta_invitation(invitee).deliver_now
      end
    end
  end

  desc "Invite particular user from waitlist"
  task invite_user: [:email,:environment] do |t, args|
    invitee = User.find_by({:email => args[:email]})
    invitee.update({:invited => true})
    if invitee.save!
      UserMailer.beta_invitation(invitee).deliver_now
    end
  end
end
