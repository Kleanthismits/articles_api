module Authentication
  class Standard < UserAuthenticator
    class AuthenticationError < StandardError; end

    attr_reader :user

    def initialize(login, password)
      @login = login
      @password = password
    end

    def perform
      authenticate_user
      set_user
    end

    private

    attr_reader :login, :password

    def authenticate_user
      raise AuthenticationError if login.blank? || password.blank?
      raise AuthenticationError unless User.exists?(login: login)
    end

    def set_user
      user = User.find_by(login: login)
      raise AuthenticationError unless user.password == password

      @user = user
    end
  end
end
