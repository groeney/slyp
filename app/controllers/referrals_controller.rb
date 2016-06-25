class ReferralsController < BaseController
  skip_before_action :ensure_request_accepts_json, only: [:new]

  def new
    @referrer = User.find_by_referral_token(params[:referral_token])
    return redirect_to root_path unless persisted_referrer
    render :new
  end

  def capture
    @referrer = User.find_by_id(params[:referred_by_id])
    return redirect_to root_path unless persisted_referrer
    @invitee = User.invite!({ email: params[:email] }, @referrer)
    return redirect_to root_path unless persisted_invitee
    if @invitee.invited?
      return render status: 201, json: { email: @invitee.email }, format: :json if @invitee.invited?
    end
    return render_404
  end

  private

  def persisted_referrer
    unless @referrer.try(:persisted?)
      flash[:notice] = "Invalid referrer token."
    end
    @referrer.try(:persisted?)
  end

  def persisted_invitee
    unless @invitee.try(:persisted?)
      flash[:notice] = "Invalid email."
    end
    @invitee.try(:persisted?)
  end
end
