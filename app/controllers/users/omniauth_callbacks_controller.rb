class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Handle both normal sign in and sign up
  # On sign up handles complete new user sign up and from invitation
  # Note: we don't accept invitation if FB user has already signed up
  def facebook
    auth = request.env["omniauth.auth"]
    user = User.find_by_invitation_token(session[:invitation_token], true)
    identity = User.where(provider: auth.provider, uid: auth.uid).first
    if identity # Sign in
      if user && user.email != identity.email
        flash[:notice] = "You used Facebook to signup with #{identity.email}."\
          " Invitation for #{user.email} not accepted."
      end
      sign_in_and_redirect(identity, event: :authentication)
    else # Sign up
      if user # From invitation
        user.apply_omniauth(auth)
        user.accept_invitation!
      else # New user
        user = User.from_omniauth(auth)
      end
      if user.valid?
        user.social_signup
        sign_in_and_redirect(user, event: :authentication)
      else
        if email_present?(auth)
          flash[:error] = "We're not sure what went wrong there but something went wrong :-("
        end
        redirect_to root_path
      end
    end
    session[:invitation_token] = nil
  end

  def failure
    redirect_to root_path
  end

  private

  def parse_user(request)
    @user = User.from_omniauth(request.env["omniauth.auth"])
  end

  def email_present?(auth)
    if auth.info.email.blank?
      flash[:error] = "Your Facebook settings don't allow us to access your "\
        "email address. Try resetting your Facebook settings under apps."
      return false
    end
    true
  end
end
