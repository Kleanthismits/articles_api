require 'rails_helper'

describe Authentication::UserAuthenticator do
  let(:user) { create :user, login: 'jsmith', password: 'secret' }

  shared_examples_for 'authenticator' do
    it "should create and set user's access token" do
      expect(authenticator.authenticator).to receive(:perform).and_return(true)
      expect(authenticator.authenticator).to receive(:user).at_least(:once).and_return(user)
      expect { authenticator.perform }.to change { AccessToken.count }.by(1)
      expect(authenticator.access_token).to be_present
    end
  end

  context 'when authenticator is initialized with code' do
    let(:authenticator) { described_class.new(code: 'sample_code') }
    let(:authenticator_class) { Authentication::Oauth }

    describe '#initialize' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with('sample_code')
        authenticator
      end

      it_behaves_like 'authenticator'
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

      it_behaves_like 'authenticator'
    end
  end
end
