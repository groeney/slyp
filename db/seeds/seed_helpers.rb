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

def reslyp(sender, recipient = pick_user)
  user_slyp = sender.user_slyps.find_or_create_by({ :slyp_id => pick_slyp.id })
  Reslyp.without_callback(:create, :after, :notify) do
    reslyp = user_slyp.send_slyp(recipient.email, pick_comment)
    if coin_flip
      begin
        reslyp.replies.create({
          :sender_id => reslyp.recipient_id,
          :text => reply_text
          })
      rescue
        puts "#################################### PROBLEM TRYING TO CREATE REPLY ####################################"
      end
    end
  end
end
