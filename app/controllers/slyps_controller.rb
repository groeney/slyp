class SlypsController < ApplicationController
  def create
    @slyp = Slyp.fetch(params[:url])
    return render status: 422, json: { url: params[:url] },
                  format: :json unless @slyp.valid?
    render status: 201, json: { url: @slyp.url, id: @slyp.id }, format: :json
  end
end
