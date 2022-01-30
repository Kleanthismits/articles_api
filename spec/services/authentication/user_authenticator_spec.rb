require 'rails_helper'

describe Authentication::UserAuthenticator do
  context 'when authenticator is initialized with code' do
    let(:authenticator) { described_class.new(code: 'sample_code') }
    let(:authenticator_class) { Authentication::Oauth }

    describe '#initialize' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('sample_code')
        authenticator
      end
    end
  end

  context 'when authenticator is initialized with login and password' do
    let(:authenticator) { described_class.new(login: 'login', password: 'password') }
    let(:authenticator_class) { Authentication::Standard }

    describe '#initialize' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('login', 'password')
        authenticator
      end
    end
  end
end
