class BaseController < ApplicationController
  before_action :ensure_request_accepts_json

  rescue_from ActiveRecord::RecordNotFound do
    render_404
  end

  rescue_from ActiveRecord::StatementInvalid do
    render status: 422, json: present_error(I18n.t("errors.422.message")),
           each_serializer: ErrorSerializer
  end

  rescue_from ActionController::ParameterMissing do
    render status: 400, json: present_error(I18n.t("errors.400.message")),
           each_serializer: ErrorSerializer
  end

  protected

  def present_error(message)
    present_errors [Error.new(message)]
  end

  def present_model_errors(model_errors)
    errors = model_errors.full_messages.map do |message|
      Error.new message
    end

    present_errors errors
  end

  def render_422(model)
    render status: 422, json: present_model_errors(model.errors),
           each_serializer: ErrorSerializer
  end

  def render_404
    render status: 404,
           json: present_error(message: I18n.t("errors.404.message")),
           each_serializer: ErrorSerializer
  end

  def render_401
    render status: 401,
           json: present_error(message: I18n.t("errors.401.message")),
           each_serializer: ErrorSerializer
  end

  def render_400
    render status: 400,
           json: present_error(message: I18n.t("errors.400.message")),
           each_serializer: ErrorSerializer
  end

  def render_403(error_msg)
    render status: 403,
           json: present_error(message: error_msg),
           each_serializer: ErrorSerializer
  end

  private

  def authenticate_user!
    return if current_user
    render_401
  end

  def ensure_request_accepts_json
    unless request.format == Mime::JSON
      render status: 406,
             json: present_error(message: I18n.t("errors.406.message")),
             each_serializer: ErrorSerializer
    end
  end

  def present_errors(errors)
    errors.map { |error| ErrorPresenter.new(error) }
  end

  class Error
    attr_accessor :message

    def initialize(message)
      @message = message
    end
  end
end
