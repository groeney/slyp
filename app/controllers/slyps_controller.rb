# NOTE: This is a non-critical controller, used for background tasks
# no response data epected
class SlypsController < ApplicationController
  def create
    url = params[:url]
    @slyp = Slyp.find_by({:url => url})
    return render status: 200, json: {url: url}, format: :json if @slyp.try(:valid?)

    @slyp = Slyp.fetch(params[:url])
    return render status: 422, json: {url: url}, format: :json if !@slyp.valid?
    render status: 201, json: {url: url}, format: :json
  end
end
