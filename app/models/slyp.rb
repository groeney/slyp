require "uri"
class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps

  validates :url, presence: true, :format => URI::regexp(%w(http https))

  def self.fetch(params)
    slyp = fetch_from_db(params[:url]) || create_from_url(params[:url])
  end

  private

  def self.fetch_from_db(url)
    Slyp.find_by(url: url)
  end

  def self.create_from_url(url)
    parsed_response = DiffbotService.fetch(url)
    Slyp.create(parsed_response)
  end
end
