class ReferralsController < BaseController
  skip_before_action :ensure_request_accepts_json, only: [:new]

  def new
    return redirect_to "/feed" if current_user
    @referrer = User.find_by_referral_token(params[:referral_token])
    return redirect_to sign_in_url unless persisted_referrer
    render :new
  end

  def capture
    @referrer = User.find_by_id(params[:referred_by_id])
    return redirect_to sign_in_url unless persisted_referrer
    @invitee = User.invite!({ email: params[:email] }, @referrer)
    return redirect_to sign_in_url unless persisted_invitee
    if @invitee.invited?
      return render status: 201, json: { email: @invitee.email }, format: :json
    end
    render_404
  end

  private

  def persisted_referrer
    msg = "Invalid referrer token."
    @referrer.try(:persisted?) && flash[:notice] = msg && true
  end

  def persisted_invitee
    @invitee.try(:persisted?) && flash[:notice] = "Invalid email." && true
  end
end
