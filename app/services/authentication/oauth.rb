module Authentication
  class Oauth < UserAuthenticator
    class AuthenticationError < StandardError; end

    attr_reader :user

    def initialize(code)
      @code = code
    end

    def perform
      raise AuthenticationError if token.blank?
      raise AuthenticationError if token.try(:error).present?

      set_user
    end

    private

    attr_reader :code

    def client
      @client ||= Octokit::Client.new(
        client_id: ENV['GITHUB_CLIENT_ID'],
        client_secret: ENV['GITHUB_CLIENT_SECRET']
      )
    end

    def token
      @token ||= client.exchange_code_for_token(code)
    end

    def user_data
      @user_data = Octokit::Client.new(
        access_token: token
      ).user.slice(:login, :url, :avatar_url, :name)
    end

    def set_user
      @user = User.find_by(login: user_data[:login]) ||
              User.create(user_data.merge(provider: 'github'))
    end
  end
end
