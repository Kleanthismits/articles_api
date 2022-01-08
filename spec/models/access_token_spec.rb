require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:access_token) { build(:access_token) }

  describe '#validations' do
    it 'tests that factory is valid' do
      expect(build(:access_token)).to be_valid
    end

    it 'validates the token' do
      access_token = create :access_token
      expect(build(:access_token, token: '')).to be_invalid
      expect(build(:access_token, token: access_token.token)).to be_invalid
    end
  end

  describe '#new' do
    it 'should have a token present after initialization' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should generate unique token' do
      user = create :user

      expect { user.create_access_token }.to change { AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'should generate token once' do
      user = create :user
      access_token = user.create_access_token
      expect(access_token.token).to eq(access_token.reload.token)
    end
  end
end
