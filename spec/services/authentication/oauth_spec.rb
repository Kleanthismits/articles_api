require 'rails_helper'

describe Authentication::Oauth do
  describe '#perform' do
    let(:authenticator) { described_class.new(code: 'sample_code') }

    subject { authenticator.perform }

    context 'when code is incorrect' do
      let(:error) do
        double('Sayer::Resource', error: 'bad_verification_code')
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return(error)
      end

      it 'should raise an error' do
        expect { subject }.to raise_error(described_class::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
      let(:user_data) do
        {
          login: 'jsmith',
          url: 'http://example.com',
          avatar_url: 'http://example.com/avatar',
          name: 'John Smith'
        }
      end
      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return('validaccesstoken')

        allow_any_instance_of(Octokit::Client).to receive(:user)
          .and_return(user_data)
      end

      it 'should save the user when does not exist' do
        expect { subject }.to change { User.count }.by 1
        expect(User.last.name).to eq('John Smith')
      end

      it 'should reuse already registered user' do
        user = create :user, user_data
        expect { subject }.not_to(change { User.count })
        expect(authenticator.user).to eq user
      end
    end
  end
end
