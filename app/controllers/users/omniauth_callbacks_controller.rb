class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    parse_user(request)
    redirect_to root_path unless omniauth_user?("Google+")
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
  end

  def facebook
    parse_user(request)
    redirect_to root_path unless email_present?(request) || omniauth_user?("Facebook")
    sign_in_and_redirect @user, event: :authentication
    set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
  end

  def failure
    redirect_to root_path
  end

  private

  def parse_user(request)
    @user = User.from_omniauth(request.env["omniauth.auth"])
  end

  def email_present?(request)
    email_required_msg = "Unfortunately we do require access to your Facebook"\
      "email. Change your Facebook Apps settings and try again :)"
    if request.env["omniauth.auth"].info.email.blank?
      flash[:error] = email_required_msg
      return false
    end
    true
  end

  def omniauth_user?(omniauth_method)
    unless @user.persisted?
      flash[:error] = "#{@user.email} did not use #{omniauth_method} to sign "\
        "up."
      return false
    end
    true
  end
end
