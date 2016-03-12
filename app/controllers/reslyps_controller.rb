class ReslypsController < BaseController
  before_action :authenticate_user!

  def create
    if ![:emails, :slyp_id, :comment].all? {|s| params.key? s}
      return render_404
    end

    user_slyp = current_user.user_slyps.find_or_create_by({:slyp_id => slyp_id})
    slyp_id = params.delete(:slyp_id)
    reslyps = user_slyp.send_slyps(params)

    reslyps.each do |both_reslyps|
      sent_reslyp, received_reslyp =
        both_reslyps[:sent_reslyp], both_reslyps[:received_reslyp]
      return render_422(sent_reslyp) if !sent_reslyp.valid?
      return render_422(received_reslyp) if !received_reslyp.valid?
    end

    sent_reslyps = reslyps.map { |both_reslyps| both_reslyps[:sent_reslyp] }
    render status: 201, json: present_collection(sent_reslyps),
      each_serializer: ReslypSerializer
  end

  def index
    user_slyp = current_user.user_slyps.find(params[:user_slyp_id])
    @reslyps = user_slyp.reslyps
    render status: 200, json: present_collection(@reslyps),
      each_serializer: ReslypSerializer
  end

  def destroy
    @reslyp = current_user.reslyps.find(params[:id])
    @reslyp_sibling = @reslyp.sibling
    return render_404 if !@reslyp_sibling

    if @reslyp.destroy and @reslyp_sibling.destroy
      head 204
    else
      head 400
    end
  end

  private

  def present(reslyp)
    ReslypPresenter.new reslyp
  end

  def present_collection(reslyps)
    reslyps.map { |reslyp| present(reslyp) }
  end
end
