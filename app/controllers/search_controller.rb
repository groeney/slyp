class SearchController < ApplicationController
  def users
    @users = User.where("email ilike :query or first_name ilike :query or user_name ilike :query",
      query: "#{params[:q]}%")
    render status: 200, json: present_users_collection(@users), each_serializer: UserSearchSerializer
  end

  def slyps
    @slyps = Slyp.where("url ilike :query or title ilike :query or :site_name ilike :query or :author ilike :query")
    render status: 200, json: present_slyp_collection(@slyps), each_serializer: SlypSerializer
  end

  private

  def present_user(user)
    UserSearchPresenter.new user
  end

  def present_users_collection(users)
    users.map { |user| present_user(user) }
  end

  def present_slyp(slyp)
    SlypPresenter.new slyp
  end

  def present_slyp_collection(slyps)
    slyps.map { |slyp| present(slyp) }
  end


end
