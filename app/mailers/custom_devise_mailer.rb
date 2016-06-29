class CustomDeviseMailer < Devise::Mailer
  default from: "James Groeneveld <james@slyp.io>"

  protected

  def subject_for(key)
    return super unless key.to_s == "invitation_instructions"
    invited_by = resource.invited_by.try(:full_name) || "Someone"
    resource.update_attribute(:invitations_count,
                              resource.invitations_count + 1)
    I18n.t("devise.mailer.invitation_instructions.subject",
           invited_by: invited_by)
  end
end
