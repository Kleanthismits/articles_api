class AccessToken < ApplicationRecord
  validates_presence_of :token
  validate :unique_token

  belongs_to :user

  after_initialize :generate_token

  private

  def generate_token
    loop do
      break if token.present? && token_already_exists?

      self.token = SecureRandom.hex(10)
    end
  end

  def token_already_exists?
    !AccessToken.where.not(id: id).exists?(token: token)
  end

  def unique_token
    return unless AccessToken.exists? token: token

    errors.add :token, 'already exists'
  end
end
