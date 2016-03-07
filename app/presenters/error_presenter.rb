class ErrorPresenter < BasePresenter
  attr_accessor :error

  delegate :message, to: :error

  def initialize(error)
    @error = error
  end
end
