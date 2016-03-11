class UsersController < BaseController
	before_action :authenticate_user!
end
