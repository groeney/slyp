class PrimaryUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :display_name,
             :notify_reslyp, :notify_activity, :weekly_summary, :searchable,
             :cc_on_reslyp_email_contact, :send_reslyp_email_from, :referral_link
end
