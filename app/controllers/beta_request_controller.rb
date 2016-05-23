class BetaRequestController < BaseController
  def create
    return render_400 unless User.find_by(email: params[:email]).nil?
    @beta_request = BetaRequest.create(email: params[:email])
    return render status: 201,
                  json: { priority: @beta_request.id } if @beta_request.valid?
    render status: 422, json: { error: @beta_request.errors.full_messages }
  end
end
