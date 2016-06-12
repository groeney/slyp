class RepliesController < BaseController
  before_action :authenticate_user!

  def create
    return render_400 unless [:reslyp_id, :text].all? { |s| params.key? s }
    @reslyp = Reslyp.authorized_find(current_user, params[:reslyp_id])
    @last_reply = @reslyp.replies.try(:last)
    attrs = { sender_id: current_user.id, text: params[:text],
              seen: @reslyp.self_reslyp? }
    @reply = @reslyp.replies.create(attrs)
    mark_last_as_seen
    return render_422(@reply) unless @reply.valid?
    render status: 201, json: present(@reply), serializer: ReplySerializer
  end

  # All replies for a particular reslyp
  # GET /reslyp/replies/:id
  def index
    return render_400 unless params.key? :id
    reslyp = Reslyp.authorized_find(current_user, params[:id])

    reslyp.replies.where.not(sender_id: current_user.id).update_all(seen: true)
    @replies = reslyp.replies.order(:created_at)
    render status: 200, json: present_collection(@replies),
           each_serializer: ReplySerializer
  end

  def update
    return render_400 unless params.key? :id
    @reply = Reply.authorized_find(current_user, params[:id])

    if @reply.update(reply_params)
      render status: 200, json: present(@reply), serializer: ReplySerializer
    else
      render_422(@reply)
    end
  end

  def destroy
    return render_400 unless params.key? :id
    @reply = Reply.authorized_find(current_user, params[:id])

    if @reply.destroy
      render status: 204, json: {}
    else
      render_422(@reply)
    end
  end

  def show
    return render_400 unless params.key? :id
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

  # For replies via quick reply feature
  def mark_last_as_seen
    valid = @last_reply && @last_reply.sender_id != current_user.id
    @last_reply.update(seen: true) if valid
  end
end
