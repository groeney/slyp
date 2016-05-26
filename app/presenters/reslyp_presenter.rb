class ReslypPresenter < BasePresenter
  attr_accessor :reslyp
  delegate :id, :sender, :recipient, :comment, :created_at,
           :reply_count, to: :reslyp

  def initialize(reslyp)
    @reslyp = reslyp
  end
end
