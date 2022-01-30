require 'rails_helper'

describe Authentication::Standard do
  describe '#perform' do
    let(:authenticator) { described_class.new('jsmith', 'password') }

    subject { authenticator.perform }

    shared_examples_for 'invalid_authentication' do
      before { user }
      it 'should raise an error' do
        expect { subject }.to raise_error(described_class::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when login is invalid' do
      let(:user) { create :user, login: 'John', password: 'password' }
      it_behaves_like 'invalid_authentication'
    end

    context 'when password is invalid' do
      let(:user) { create :user, login: 'jsmith', password: 'wrong' }
      it_behaves_like 'invalid_authentication'
    end

    context 'when credentials are valid' do

    end
  end
end
