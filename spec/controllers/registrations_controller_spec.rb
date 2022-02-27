require 'rails_helper'

RSpec.describe RegistrationsController do
  describe '#create' do
    subject { post :create, params: params }
    context 'when invalid data provided' do
      let(:params) { { data: { attributes: { login: nil, password: nil } } } }

      it 'should return unprocessable status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should not create a user' do
        expect { subject }.not_to(change { User.count })
      end

      it 'should contain error messages in response body' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/login' },
            'detail' => "Login can't be blank"
          },
          {
            'source' => { 'pointer' => '/data/attributes/password' },
            'detail' => "Password can't be blank"
          }
        )
      end
    end

    context 'when valid data provided' do
      let(:params) { { data: { attributes: { login: 'jsmith', password: 'password' } } } }
      it 'should return created status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should create a user' do
        expect(User.exists?(login: 'jsmith')).to be_falsey
        expect { subject }.to(change { User.count }.by(1))
        expect(User.exists?(login: 'jsmith')).to be_truthy
      end
    end
  end
end
