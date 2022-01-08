require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article) { build(:article) }

  describe '#validations' do
    it 'tests that factory is valid' do
      expect(article).to be_valid
      article.save!
      another_article = build(:article)

      expect(another_article).to be_valid
    end

    it 'has an invalid title' do
      article.title = ''
      expect(article).not_to be_valid
      expect(article.errors['title']).to include("can't be blank")
    end

    it 'has invalid content' do
      article.content = ''
      expect(article).not_to be_valid
      expect(article.errors['content']).to include("can't be blank")
    end

    it 'has invalid slug' do
      article.slug = ''
      expect(article).not_to be_valid
      expect(article.errors['slug']).to include("can't be blank")
    end

    it 'validates the uniqueness of the slug' do
      article1 = create(:article)
      expect(article1).to be_valid

      article2 = build(:article, slug: article1.slug)
      expect(article2).not_to be_valid
      expect(article2.errors['slug']).to include('has already been taken')

    end
  end

  describe '.recent' do
    it 'returns articles in the proper order' do
      older_article = create(:article, created_at: 1.hour.ago)
      article = create(:article)

      expect(described_class.recent).to eq [article, older_article]

      article.update_column(:created_at, 2.hours.ago)

      expect(described_class.recent).to eq [older_article, article]
    end
  end
end
