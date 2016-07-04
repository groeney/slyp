class UsersController < BaseController
  before_action :authenticate_user!, only: [:update, :update_password, :index]

  def beta_request
    return render_400 unless (email = params[:email])
    unless (@user = User.find_by(email: email))
      invite_attrs = { email: email, skip_invitation: true }
      @user = User.invite!(invite_attrs, User.support_user)
      @user.add_to_waitlist
    end
    unless @user.valid?
      return render status: 422, json: { error: @user.errors.full_messages }
    end
    render status: 201, json: { priority: @user.id, status: @user.status }
  end

  def update
    return render_422(current_user) unless current_user.update(user_params)
    render status: 200, json: present(current_user),
           serializer: PrimaryUserSerializer
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(user_password_params)
      sign_in @user, bypass: true
      render status: 200, json: present(current_user),
             serializer: PrimaryUserSerializer
    else
      render_401
    end
  end

  def index
    render status: 200, json: present(current_user),
           serializer: PrimaryUserSerializer
  end

  private

  def present(user)
    PrimaryUserPresenter.new user
  end

  def user_params
    params.require(:user).permit(user_attrs)
  end

  def user_attrs
    [:first_name, :last_name, :email, :notify_reslyp, :notify_activity,
     :searchable, :cc_on_reslyp_email_contact, :send_reslyp_email_from,
     :weekly_summary]
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password)
  end
end
