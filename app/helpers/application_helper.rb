module ApplicationHelper
  def ensure_valid_oauth_params(auth)
    unless auth.info.first_name && auth.info.last_name
      names = auth.info.name.split(" ")
      auth.info.first_name = names.shift || ""
      auth.info.last_name = names.join(" ")
    end
    return auth
  end

  def parse_oauth_params(auth)
    auth = ensure_valid_oauth_params(auth)
    return auth.provider, auth.uid, auth.info.email
  end
end
