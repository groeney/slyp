class SlypsController < ApplicationController
  def create
    @slyp = Slyp.fetch(params)
    return render status: 422, json: { :errors => @slyp.errors.full_messages } if !@slyp.valid?
    render status: 201, json: present(@slyp), serializer: SlypSerializer
  end

  private

  def present(slyp)
    SlypPresenter.new slyp
  end
end
