class ApplicationMailer < ActionMailer::Base
  default 'from' => Proc.new { "James Groeneveld <james+#{SecureRandom.hex(3)}@slyp.io>" }
end
