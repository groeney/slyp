class UsersController < BaseController
  before_action :authenticate_user!

  def index
    @users = User.all_except(current_user)
    render status: 200, json: present_collection(@users),
           each_serializer: UserSerializer
  end

  def update
    return render_422(current_user) unless current_user.update(user_params)
    render status: 200, json: present_primary(current_user),
           serializer: PrimaryUserSerializer
  end

  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(user_password_params)
      sign_in @user, bypass: true
      render status: 200, json: present_primary(current_user),
             serializer: PrimaryUserSerializer
    else
      render_401
    end
  end

  def friends
    @friends = current_user.friends
    render status: 200, json: present_collection(@friends),
           each_serializer: UserSerializer
  end

  def show
    render status: 200, json: present_primary(current_user),
           serializer: PrimaryUserSerializer
  end

  private

  def present(user)
    UserPresenter.new user
  end

  def present_collection(users)
    users.map { |user| present(user) }
  end

  def present_primary(user)
    PrimaryUserPresenter.new user
  end

  def user_params
    params.require(:user).permit(:notify_reslyp, :notify_activity, :searchable,
                                 :cc_me_on_email_reslyp, :weekly_summary,
                                 :first_name, :last_name, :email,
                                 :send_reslyp_email_from)
  end

  def user_password_params
    params.require(:user).permit(:current_password, :password)
  end
end
