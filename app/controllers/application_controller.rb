class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end
  include JsonapiErrorsHandler
  ErrorMapper.map_errors!(
    {
      'ActiveRecord::RecordNotFound' => 'JsonapiErrorsHandler::Errors::NotFound',
      'ActiveRecord::RecordInvalid' => 'JsonapiErrorsHandler::Errors::Invalid'
    }
  )
  rescue_from ::StandardError, with: ->(e) { handle_error(e) }
  rescue_from Authentication::Oauth::AuthenticationError, with:
    :authentication_oauth_error
  rescue_from Authentication::Standard::AuthenticationError, with:
   :authentication_standard_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  private

  def authentication_oauth_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide a valid code in order to exchange it for token'
    }
    render json: { 'errors' => [error] }, status: 401
  end

  def authentication_standard_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/data/attributes/password' },
      'title' => 'Invalid login or password',
      'detail' => 'You must provide valid credentials in order to exchange them for token'
    }
    render json: { 'errors' => [error] }, status: 401
  end

  def authorization_error
    error = {
      status: '403',
      source: { pointer: '/headers/authorization' },
      title: 'Not authorized',
      detail: 'You have no right to access this resource'
    }
    render json: { 'errors' => [error] }, status: 403
  end

  def not_found_error
    error = {
      status: '404',
      source: { pointer: '/request/url/:id' },
      title: 'Not found',
      detail: 'The requested resource does not exist'
    }
    render json: { 'errors' => [error] }, status: 404
  end
end
