class BetaRequestController < BaseController
  def create
    return render_400 if !User.find_by({:email => params[:email]}).nil?
    @beta_request = BetaRequest.create({:email => params[:email]})
    if @beta_request.valid?
      render status: 201, json: { priority: @beta_request.id }
    else
      render status: 422, json: { error: @beta_request.errors.full_messages }
    end
  end
end
