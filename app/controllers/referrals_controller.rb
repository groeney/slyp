class ReferralsController < ApplicationController
  def new
    @referrer = User.find_by_referral_token(params[:referral_token])
    return redirect_to root_path unless persisted_referrer
    render :new
  end

  def capture
    @referrer = User.find_by_id(params[:referred_by_id])
    return redirect_to root_path unless persisted_referrer
    @invitee = User.invite!({ email: params[:email] }, @referrer) do |u|
      u.skip_invitation = true
    end
    return redirect_to root_path unless valid_invitee
    attrs = { invitation_token: @invitee.raw_invitation_token }
    return redirect_to Rails.application.routes.url_helpers
                            .accept_user_invitation_path(@invitee, attrs)
  end

  private

  def persisted_referrer
    unless @referrer.try(:persisted?)
      flash[:notice] = "Invalid referrer token."
    end
    @referrer.try(:persisted?)
  end

  def valid_invitee
    if !@invitee.try(:persisted?)
      flash[:notice] = "Invalid user attributes."
    elsif @invitee.try(:active?)
      flash[:notice] = "Email #{@invitee.email} has already been taken."
    end
    @invitee.try(:persisted?) && @invitee.try(:invited?)
  end
end
