class SearchController < BaseController
  def users
    @users = parse_and_query_users(params[:q])
    render status: 200, json: present_users_collection(@users),
           each_serializer: UserSearchSerializer
  end

  def friends
    user_query = params[:q]
    user_query[0] = "" if user_query[0] == "@"
    @matching_users = parse_and_query_users(user_query)
    @friends = current_user.friends.where(id: @matching_users.pluck(:id))
    render status: 200, json: present_users_collection(@friends),
           each_serializer: UserSearchSerializer
  end

  def user_slyps
    @user_slyps = parse_and_query_user_slyps(params[:q])
    render status: 200, json: present_user_slyp_collection(@user_slyps),
           each_serializer: UserSlypSerializer
  end

  def mutual_user_slyps
    friend_id = params[:friend_id].to_i
    @user_slyps = current_user.find_mutual_user_slyps(friend_id)
                              .order(unseen_activity: :desc, updated_at: :desc)
    render status: 200, json: present_user_slyp_collection(@user_slyps),
           each_serializer: UserSlypSerializer
  end

  private

  def parse_and_query_users(user_query)
    query = "email ilike :user_query or LOWER(first_name || ' ' || last_name)"\
      " ilike :user_query"
    User.where(query, user_query: "%#{user_query}%").where
                                                    .not(id: current_user.id)
  end

  def parse_and_query_user_slyps(user_query)
    query = "url ilike :query or title ilike :flexi_query"\
            " or site_name ilike :flexi_query or author ilike :flexi_query"\
            " or description ilike :flexi_query"
    slyp_ids = current_user.slyps.where(
      query, query: "#{user_query}%", flexi_query: "%#{user_query}%").pluck :id
    current_user.user_slyps.where(slyp_id: slyp_ids)
  end

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
