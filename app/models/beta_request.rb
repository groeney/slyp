class BetaRequest < ActiveRecord::Base
  validates_uniqueness_of :email, message: "has already been submitted."
end
