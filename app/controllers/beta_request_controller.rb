class BetaRequestController < BaseController
  def create
    @beta_request = BetaRequest.create({:email => beta_request_params})
    if @beta_request.valid?
      UserMailer.beta_request_email(@beta_request).deliver_later
      render status: 201, json: { priority: @beta_request.id }
    else
      render status: 422, json: { error: @beta_request.errors.full_messages }
    end
  end
  private
  def beta_request_params
    params.require(:email)
  end
end
