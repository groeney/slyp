class RepliesController < BaseController
  before_action :authenticate_user!

  def create
    return render_400 unless reslyp_id = params[:reslyp_id]
    @reslyp = current_user.reslyps.find(reslyp_id)
    @last_reply = @reslyp.replies.try(:last)
    reply_attrs = { sender_id: current_user.id, text: params[:text],
              seen: @reslyp.self_reslyp? }
    @reply = @reslyp.replies.create(reply_attrs)
    update_user_notifications
    return render_422(@reply) unless @reply.valid?
    render status: 201, json: present(@reply), serializer: ReplySerializer
  end

  # All replies for a particular reslyp
  # GET /reslyp/replies/:id
  def index
    reslyp = current_user.reslyps.find(params[:id])
    reslyp.replies.where.not(sender_id: current_user.id).update_all(seen: true)
    @replies = reslyp.replies.order(:created_at)
    render status: 200, json: present_collection(@replies),
           each_serializer: ReplySerializer
  end

  def update
    @reply = current_user.replies.find(params[:id])
    if @reply.update(reply_params)
      render status: 200, json: present(@reply), serializer: ReplySerializer
    else
      render_422(@reply)
    end
  end

  def destroy
    @reply = current_user.replies.find(params[:id])
    if @reply.destroy
      render status: 204, json: {}
    else
      render_422(@reply)
    end
  end

  def show
    @reply = current_user.replies.find(params[:id])
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

  def update_user_notifications
    valid = @last_reply && @last_reply.sender_id != current_user.id
    @last_reply.update(seen: true) if valid
    if current_user.id.eql? @reslyp.recipient_id
      @reslyp.recipient_user_slyp.touch
      @reslyp.sender_user_slyp.update(unseen_activity: true)
    else
      @reslyp.sender_user_slyp.touch
      @reslyp.recipient_user_slyp.update(unseen_activity: true)
    end
  end
  end
end
