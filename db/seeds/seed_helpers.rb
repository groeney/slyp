def pick_comment
  @comments.sample
end

def pick_reply
  @replies.sample
end

def pick_first_name
  @first_names.sample
end

def coin_flip
  [true, false].sample
end

def pick_user(except = nil)
  User.where.not(id: except).sample
end

def pick_slyp(except = nil)
  Slyp.where.not(id: except).sample
end

def reply(reslyp)
  return unless reslyp.try(:valid?)
  reslyp.replies.create(
    sender_id: reslyp.recipient_id,
    text: pick_reply
  )
end

def perform_reslyp(sender, recipient = pick_user)
  user_slyp = sender.user_slyps.find_or_create_by(slyp_id: pick_slyp.id)
  reslyp = nil
  Reslyp.without_callback(:create, :after, :notify) do
    begin
      reslyp = user_slyp.send_slyp(recipient.email, pick_comment)
      reslyp.save!
    rescue ActiveRecord::RecordInvalid
      puts "!@# Couldn't send slyp #@!"
    end
  end
  reply(reslyp) if coin_flip
end
