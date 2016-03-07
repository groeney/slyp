class SlypsController < ApplicationController
  before_action :authenticate_user!

  def create
    @slyp = Slyp.fetch(params)
    return render status: 422, json: { :errors => @slyp.errors.full_messages } if !@slyp.valid?
    @user_slyp = UserSlyp.create({
      slyp_id: @slyp.id,
      user_id: current_user.id
      })
    render status: 201, json: present(@slyp), serializer: SlypSerializer
  end

  private

  def present(slyp)
    current_user_slyp = UserSlyp.find_by({:user_id => current_user.id, :slyp_id => slyp.id})
    SlypPresenter.new slyp, current_user_slyp
  end
end
