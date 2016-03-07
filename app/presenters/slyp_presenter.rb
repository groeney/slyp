class SlypPresenter < BasePresenter
  attr_accessor :slyp, :user_slyp

  delegate :id, :duration, :display_url, :title, :site_name, :author, to: :slyp

  def initialize(slyp, user_slyp)
    @slyp = slyp
    @user_slyp = user_slyp
  end

  def archived
    @user_slyp.archived
  end

  def favourite
    @user_slyp.favourite
  end

  def deleted
    @user_slyp.deleted
  end
end
