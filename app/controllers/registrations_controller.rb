class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    "feed"
  end

  def after_sign_in_path_for(resource)
    "feed"
  end
end