class EmailAddressFilter
  def self.delivering_email(message)
    message.perform_deliveries = false

    # your checks here; return if @abc.com, etc.. is matched
    return unless message.to.join("").match(/@example.com/).nil? or ENV.fetch("RAILS_ENV", "") == "test"

    # otherwise, the email should be sent
    message.perform_deliveries = true
  end
end

ActionMailer::Base.register_interceptor(EmailAddressFilter)