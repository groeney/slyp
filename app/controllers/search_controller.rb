class SearchController < ApplicationController
  def users
    @users = User.where("email ilike :query or first_name ilike :query"\
    " or user_name ilike :query", query: "#{params[:q]}%")
    render status: 200, json: present_users_collection(@users), each_serializer: UserSearchSerializer
  end

  def user_slyps
    authenticate_user!
    slyp_ids = current_user.slyps.where("url ilike :query or title ilike :flexi_query"\
    " or site_name ilike :flexi_query or author ilike :flexi_query or text ilike :flexi_query",
    query:"#{params[:q]}%", flexi_query: "%#{params[:q]}%").pluck(:id)
    @user_slyps = current_user.user_slyps.where(slyp_id: slyp_ids)
    render status: 200, json: present_user_slyp_collection(@user_slyps), each_serializer: UserSlypSerializer
  end

  private

  def present_user(user)
    UserSearchPresenter.new user
  end

  def present_users_collection(users)
    users.map { |user| present_user(user) }
  end

  def present_user_slyp(user_slyp)
    UserSlypPresenter.new user_slyp
  end

  def present_user_slyp_collection(user_slyps)
    user_slyps.map { |user_slyp| present_user_slyp(user_slyp) }
  end


end
