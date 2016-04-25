class UserSlypsController < BaseController
  before_action :authenticate_user!
  def create
    @slyp = Slyp.fetch(params[:url])
    return render_422(@slyp) if !@slyp.valid?

    @user_slyp = current_user.user_slyps.find_or_create_by({:slyp_id => @slyp.id})
    return render_422(@user_slyp) if !@user_slyp.valid?
    render status: 201, json: present(@user_slyp), serializer: UserSlypSerializer
  end

  def index
    @user_slyps = current_user.user_slyps.where({:archived => false, :deleted => false}).order(updated_at: :desc)
    render status: 200, json: present_collection(@user_slyps), each_serializer: UserSlypSerializer
  end

  def show
    @user_slyp = current_user.user_slyps.find(params[:id])
    render status: 200, json: present(@user_slyp), serializer: UserSlypSerializer
  end

  def update
    @user_slyp = current_user.user_slyps.find(params[:id])
    if @user_slyp.update(user_slyp_params)
      render status: 200, json: present(@user_slyp), serializer: UserSlypSerializer
    else
      render_422(@user_slyp)
    end
  end

  private

  def present(user_slyp)
    UserSlypPresenter.new user_slyp
  end

  def present_collection(user_slyps)
    user_slyps.map { |user_slyp| present(user_slyp) }
  end

  def user_slyp_params
    params.require(:user_slyp).permit(:archived, :deleted, :favourite)
  end
end
