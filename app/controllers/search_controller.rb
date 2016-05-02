class SearchController < ApplicationController
  def users
    search_parts = params[:q].split
    first_part = search_parts[0]
    second_part = search_parts.try(:[], 1)
    if second_part.nil?
      @users = User.where("email ilike :first_part or first_name ilike :first_part", first_part: "#{first_part}%").where.not(id: current_user.try(:id))
    else
      @users = User.where("email ilike :first_part or first_name ilike :first_part or last_name ilike :second_part", first_part: "#{first_part}%", second_part: "#{second_part}%").where.not(id: current_user.try(:id))
    end
    render status: 200, json: present_users_collection(@users), each_serializer: UserSearchSerializer
  end

  def user_slyps
    authenticate_user!
    slyp_ids = current_user.slyps.where("url ilike :query or title ilike :flexi_query"\
    " or site_name ilike :flexi_query or author ilike :flexi_query or description ilike :flexi_query",
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
