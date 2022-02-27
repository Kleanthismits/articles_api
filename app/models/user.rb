class User < ApplicationRecord
  validates_presence_of :login, :provider
  validates_presence_of :password, if: -> { provider == 'standard' }
  validate :unique_login

  has_one :access_token, dependent: :destroy
  has_many :articles
  has_many :comments, dependent: :destroy

  def password
    @password ||= BCrypt::Password.new(encrypted_password) if encrypted_password.present?
  end

  def password=(new_password)
    self.encrypted_password = BCrypt::Password.create(new_password) unless new_password.blank?
  end

  private

  def unique_login
    return unless User.exists? login: login

    errors.add :login, 'has already been taken'
  end
end
