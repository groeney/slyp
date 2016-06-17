class UpdateSlypHtmlFromInsecureIframe < ActiveRecord::Migration
  def change
    insecure_iframe = "iframe src=\"http:"
    secure_iframe = "iframe src=\"https:"
    Slyp.where("html ilike ?", "%#{insecure_iframe}%").each do |slyp|
      slyp.update(html: slyp.html.gsub(insecure_iframe, secure_iframe))
    end
  end
end
