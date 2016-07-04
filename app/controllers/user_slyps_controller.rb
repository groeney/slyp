class UserSlypsController < BaseController
  before_action :authenticate_user!
  def create
    @slyp = Slyp.fetch(params[:url])
    return render_422(@slyp) unless @slyp.valid?
    @user_slyp = current_user.user_slyps.find_or_create_by(slyp_id: @slyp.id)
    return render_422(@user_slyp) unless @user_slyp.valid?
    render status: 201, json: present(@user_slyp),
           serializer: UserSlypSerializer
  end

  def index
    @user_slyps = fetch_filtered_user_slyps
    render status: 200, json: present_collection(@user_slyps),
           each_serializer: UserSlypSerializer
  end

  def show
    @user_slyp = current_user.user_slyps.find(params[:id])
    render status: 200, json: present(@user_slyp, true),
           serializer: UserSlypSerializer
  end

  def update
    @user_slyp = current_user.user_slyps.find(params[:id])
    return render_422(@user_slyp) unless @user_slyp.update(user_slyp_params)
    render status: 200, json: present(@user_slyp, true),
           serializer: UserSlypSerializer
  end

  def touch
    @user_slyp = current_user.user_slyps.find(params[:id])
    @user_slyp.touch
    render status: 204, json: {}
  end

  private

  def present(user_slyp, show_html = false)
    UserSlypPresenter.new user_slyp, show_html
  end

  def present_collection(user_slyps)
    user_slyps.includes(:slyp).map { |user_slyp| present(user_slyp) }
  end

  def user_slyp_params
    params.require(:user_slyp).permit(:archived, :deleted, :favourite, :unseen,
                                      :unseen_activity)
  end

  def fetch_filtered_user_slyps
    step = params[:step] || 10
    offset_by = params[:offset] || 0
    sql_ordering = { updated_at: :desc }

    if (friend_id = params[:friend_id])
      current_user.mutual_user_slyps(friend_id).order(sql_ordering)
                  .offset(offset_by).limit(step)
    elsif params[:recent]
      recent_query = "archived = false AND (updated_at >= ? "\
                     "or unseen_activity = true)"
      current_user.user_slyps.where(recent_query, 1.week.ago)
                  .order(sql_ordering).offset(offset_by).limit(step)
    else
      current_user.user_slyps.order(sql_ordering).offset(offset_by).limit(step)
    end
  end
end
