# NOTE: This is a non-critical controller, used for background tasks
# no response data epected
class SlypsController < ApplicationController
  def create
    @slyp = Slyp.find_by({:url => params[:url]})
    return head 200 if @slyp.try(:valid?)

    @slyp = Slyp.fetch(params[:url])
    return head 422 if !@slyp.valid?

    head 201
  end
end
