class RepliesController < ApplicationController
  def create
    reslyp = Reslyp.authorized_find(current_user, params[:reslyp_id])
    return render_404 if reslyp.nil? or !reslyp.try(:valid?)

    @reply = reslyp.replies.create({
      :sender_id => current_user.id,
      :reply => params[:reply]
      })
    return render_422(@reply) if !@reply.valid?
    render status: 201, json: present(@reply), serializer: ReplySerializer
  end

  def index
    reslyp = Reslyp.authorized_find(current_user, params[:reslyp_id])
    return render_404 if reslyp.nil? or !reslyp.try(:valid?)

    @replies = reslyp.replies
    render status: 200, json: present_collection(@replies), each_serializer: ReplySerializer
  end

  def update
    @reply = Reply.authorized_find(current_user, params[:reply_id])
    return render_404 if @reply.nil? or !@reply.try(:valid?)

    if @reply.update(reply_params)
      render status: 200, json: present(@reply), serializer: ReplySerializer
    else
      render_422(@reply)
    end
  end

  def destroy
    @reply = Reply.authorized_find(current_user, params[:reply_id])
    return render_404 if @reply.nil? or !@reply.try(:valid?)

    if @reply.destroy()
      render status: 204, json: {}
    else
      render_422(@reply)
    end
  end

  private

  def present(reply)
    ReplyPresenter.new reply
  end

  def present_collection(replies)
    replies.map { |reply| present(reply) }
  end

  def reply_params
    params.require(:reply).permit(:reply)
  end
end
