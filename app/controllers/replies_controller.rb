class RepliesController < BaseController
  before_action :authenticate_user!
  def create
    if [:reslyp_id, :text].all? {|s| params.key? s}
      reslyp = Reslyp.authorized_find(current_user, params[:reslyp_id])
      return render_401 if !reslyp.try(:valid?)

      @reply = reslyp.replies.create({
        :sender_id => current_user.id,
        :text => params[:text]
        })
      return render_422(@reply) if !@reply.valid?
      render status: 201, json: present(@reply), serializer: ReplySerializer
    else
      return render_400
    end
  end

  # All replies for a particular reslyp
  # GET /reslyp/replies/:id
  def index
    return render_400 if !params.key? :id
    reslyp = Reslyp.authorized_find(current_user, params[:id])

    @replies = reslyp.replies
    render status: 200, json: present_collection(@replies), each_serializer: ReplySerializer
  end

  def update
    return render_400 if !params.key? :id
    @reply = Reply.authorized_find(current_user, params[:id])

    if @reply.update(reply_params)
      render status: 200, json: present(@reply), serializer: ReplySerializer
    else
      render_422(@reply)
    end
  end

  def destroy
    return render_400 if !params.key? :id
    @reply = Reply.authorized_find(current_user, params[:id])

    if @reply.destroy()
      render status: 204, json: {}
    else
      render_422(@reply)
    end
  end

  def show
    return render_400 if !params.key? :id
    @reply = Reply.authorized_find(current_user, params[:id])

    render status: 200, json: present(@reply), serializer: ReplySerializer
  end

  private

  def present(reply)
    ReplyPresenter.new reply
  end

  def present_collection(replies)
    replies.map { |reply| present(reply) }
  end

  def reply_params
    params.require(:reply).permit(:text)
  end
end
