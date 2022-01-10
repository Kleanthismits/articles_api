require 'rails_helper'

shared_examples_for 'unauthorized_requests' do
  let(:github_error) do
    double('Sayer::Resource', error: 'bad_verification_code')
  end

  before do
    allow_any_instance_of(Octokit::Client).to receive(
      :exchange_code_for_token
    ).and_return(github_error)
  end

  let(:authentication_error) do
    {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide a valid code in order to exchange it for token'
    }
  end

  it 'should return 401 status code' do
    subject
    expect(response).to have_http_status(401)
  end

  it 'should return proper error' do
    subject
    expect(json['errors']).to include(authentication_error)
  end
end

shared_examples_for 'forbidden_requests' do
  let(:authorization_error) do
    {
      'status' => '403',
      'source' => { 'pointer' => '/headers/authorization' },
      'title' => 'Not authorized',
      'detail' => 'You have no right to access this resource'
    }
  end

  it 'returns 403 status code' do
    subject
    expect(response).to have_http_status(:forbidden)
  end

  it 'should return proper error json' do
    subject
    expect(json['errors']).to include(authorization_error)
  end
end
