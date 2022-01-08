class AccessTokensController < ApplicationController
  skip_before_action :authorize!, only: :create

  def create
    authenticator = Authentication::UserAuthenticator.new(params[:code])
    authenticator.perform

    render json: serializer.new(authenticator.access_token), status: :created
  end

  def destroy
    current_user.access_token.destroy
  end

  private

  def serializer
    AccessTokenSerializer
  end
end
