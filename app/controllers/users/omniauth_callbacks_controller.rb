class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      flash[:error] = "It looks like you didn't use Google to sign up #{@user.email}"
      redirect_to root_path
    end
  end

  def facebook
    if request.env["omniauth.auth"].info.email.blank?
      flash[:error] = "Unfortunately we require access to your Facebook email. Change your Facebook Apps settings and try again :)"
      redirect_to root_path
    else
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        flash[:error] = "It looks like you didn't use Facebook to sign up #{@user.email}"
        redirect_to root_path
      end
    end
  end

  def failure
    redirect_to root_path
  end
end
