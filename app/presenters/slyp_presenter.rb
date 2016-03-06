class SlypPresenter < BasePresenter
  attr_accessor :slyp

  delegate :id, :display_url, :title, :site_name, :author, to: :slyp

  def initialize(slyp)
    @slyp = slyp
  end
end
