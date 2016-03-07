class BaseController < ApplicationController
  before_action :ensure_request_accepts_json

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render status: 404, json: present_error(message: I18n.t("errors.404.message")),
      each_serializer: ErrorSerializer
  end

  protected

  def present_error(message: message)
    present_errors [Error.new(message: message)]
  end

  def present_model_errors(model_errors)
    errors = model_errors.full_messages.map do |message|
      Error.new message: message
    end

    present_errors errors
  end

  private

  def authenticate_user!
    unless current_user
      render status: 401, json: present_error(message: I18n.t("errors.401.message")),
        each_serializer: ErrorSerializer
    end
  end

  def ensure_request_accepts_json
    unless request.format == Mime::JSON
      render status: 406, json: present_error(message: I18n.t("errors.406.message")),
        each_serializer: ErrorSerializer
    end
  end

  def present_errors(errors)
    errors.map { |error| ErrorPresenter.new(error) }
  end

  class Error
    attr_accessor :message

    def initialize(message: message)
      @message = message
    end
  end
end
