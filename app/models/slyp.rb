class Slyp < ActiveRecord::Base
  has_many :user_slyps
  has_many :users, through: :user_slyps

  validates :url, :url => true, presence: true

  def self.fetch(url)
    slyp = fetch_from_db(url) || create_from_url(url)
  end

  private

  def self.fetch_from_db(url)
    Slyp.find_by(url: url)
  end

  def self.create_from_url(url)
    parsed_response = DiffbotService.fetch(url)
    Slyp.find_or_create_by(parsed_response)
  end
end
