class User < ApplicationRecord
  validates_presence_of :login, :provider
  validate :unique_login

  has_one :access_token, dependent: :destroy
  has_many :articles
  has_many :comments, dependent: :destroy

  private

  def unique_login
    return unless User.exists? login: login

    errors.add :login, 'has already been taken'
  end
end
