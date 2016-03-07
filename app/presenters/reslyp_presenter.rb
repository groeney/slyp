class ReslypPresenter < BasePresenter
  attr_accessor :reslyp

  delegate :id, :sender, :user, to: :reslyp

  def initialize(reslyp)
    @reslyp = reslyp
  end
end
