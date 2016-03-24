class HomeController < ApplicationController
  def index
  end

  def feed
    authenticate_user!
  end
end
