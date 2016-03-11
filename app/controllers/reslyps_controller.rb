class ReslypsController < BaseController
  before_action :authenticate_user!

  def create
    @user_slyp = current_user.user_slyps.find(params[:user_slyp_id])
    @to_user = User.find(params[:to_user_id])

    @to_user_slyp = @to_user.user_slyps.find_or_create_by({
      :slyp_id => @user_slyp.slyp_id
      })
    return render status: 422, json: present_model_errors(@to_user_slyp.errors),
      each_serializer: ErrorSerializer if !@to_user_slyp.valid?

    @sent_reslyp = Reslyp.send_reslyp(@to_user_slyp, @user_slyp)
    return render status: 422, json: present_model_errors(@sent_reslyp.errors),
      each_serializer: ErrorSerializer if !@sent_reslyp.valid?

    @received_reslyp = @sent_reslyp.receive_reslyp(params[:comment])
    return render status: 422, json: present_model_errors(@received_reslyp.errors),
      each_serializer: ErrorSerializer if !@received_reslyp.valid?

    render status: 201, json: present(@sent_reslyp), serializer: ReslypSerializer
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
    return render status: 404, json: present_error(message: I18n.t("errors.404.message")),
      each_serializer: ErrorSerializer if !@reslyp_sibling

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
