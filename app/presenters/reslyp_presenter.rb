class ReslypPresenter < BasePresenter
  attr_accessor :reslyp

  delegate :id, :sender, :user, :comment, :created_at, to: :reslyp

  def initialize(reslyp)
    @reslyp = reslyp
  end
end
