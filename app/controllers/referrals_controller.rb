class ReferralsController < ApplicationController
  def new
    @referrer = User.find_by_referral_token(params[:referral_token])
    return redirect_to root_path unless valid_referrer
    render :new
  end

  def capture
    @referrer = User.find_by_id(params[:referred_by_id])
    return redirect_to root_path unless valid_referrer
    @invitee = User.invite!({ email: params[:email] }, @referrer) do |u|
      u.skip_invitation = true
    end
    return redirect_to root_path unless valid_invitee
    attrs = { invitation_token: @invitee.raw_invitation_token }
    return redirect_to Rails.application.routes.url_helpers
                            .accept_user_invitation_path(@invitee, attrs)
  end

  private

  def valid_referrer
    unless @referrer.try(:valid?)
      flash[:notice] = "Invalid referrer token."
    end
    @referrer.try(:valid?)
  end

  def valid_invitee
    unless @invitee.try(:valid?)
      flash[:notice] = "Invalid invitee."
    end
    @invitee.try(:valid?)
  end
end
