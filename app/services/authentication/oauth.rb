module Authentication
  class Oauth < UserAuthenticator
    class AuthenticationError < StandardError; end

    attr_reader :user, :access_token

    def initialize(code)
      @code = code
    end

    def perform
      raise AuthenticationError if token.blank?
      raise AuthenticationError if token.try(:error).present?

      prepare_user
      prepare_access_token
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

    def prepare_user
      @user = User.find_by(login: user_data[:login]) ||
              User.create(user_data.merge(provider: 'github'))
    end

    def prepare_access_token
      @access_token = user.access_token || user.create_access_token
    end
  end
end
