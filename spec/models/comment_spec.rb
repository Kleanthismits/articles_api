require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#validations' do
    let(:comment) { build(:comment) }

    it 'should have valid factory' do
      expect(comment).to be_valid
    end

    it 'has an invalid user' do
      comment.user = nil
      expect(comment).not_to be_valid
      expect(comment.errors['user']).to include('must exist')
    end

    it 'has an invalid article' do
      comment.article = nil
      expect(comment).not_to be_valid
      expect(comment.errors['article']).to include('must exist')
    end

    it 'has an invalid content' do
      comment.content = ''
      expect(comment).not_to be_valid
      expect(comment.errors['content']).to include("can't be blank")
    end
  end
end
