class FriendshipsController < BaseController
  before_action :authenticate_user!
  def create
    @friendship = current_user.befriend(params[:user_id])
    return render_400 unless @friendship.try(:valid?)
    render status: 201, json: present(@friendship),
           serializer: FriendshipSerializer
  end

  def index
    @friendships = current_user.friendships
    render status: 200, json: present_collection(@friendships),
           each_serializer: FriendshipSerializer
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id])
    if @friendship.destroy
      render status: 204, json: {}
    else
      render_422(@friendship)
    end
  end

  private

  def present(friendship)
    FriendshipPresenter.new friendship
  end

  def present_collection(friendships)
    friendships.map { |friendship| present(friendship) }
  end
end
