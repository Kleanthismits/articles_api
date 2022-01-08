require 'rails_helper'

RSpec.describe ArticlesController do
  describe '#index' do
    it 'returns a success response' do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it 'returns a proper JSON' do
      article = create :article
      get :index

      expect(json_data.length).to eq(1)
      expected = json_data.first

      aggregate_failures do
        expect(expected[:id]).to eq article.id.to_s
        expect(expected[:type]).to eq 'article'
        expect(expected[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end

    it 'returns articles in the proper order' do
      older_article = create(:article, created_at: 1.hour.ago)
      article = create(:article)
      get :index

      ids = json_data.map { |item| item[:id].to_i }

      expect(ids).to eq([article.id, older_article.id])
    end

    it 'paginates results' do
      article1, article2, article3 = create_list(:article, 3)

      get :index, params: { page: { number: 2, size: 1 } }

      expect(json_data.length).to eq 1
      expect(json_data.first[:id]).to eq article2.id.to_s
    end

    it 'contains pagination links in the response' do
      article1, article2, article3 = create_list(:article, 3)

      get :index, params: { page: { number: 2, size: 1 } }

      expect(json[:links].length).to eq 5
      expect(json[:links].keys).to eq %i[first prev self next last]
    end
  end

  describe '#show' do
    let(:article) { create :article }

    subject { get :show, params: { id: article.id } }

    before { subject }

    it 'returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a proper JSON' do
      aggregate_failures do
        expect(json_data[:id]).to eq(article.id.to_s)
        expect(json_data[:type]).to eq('article')
        expect(json_data[:attributes]).to eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        )
      end
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no authorization provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid authorization provided' do
      before { request.headers['authorization'] = 'invalid_token' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error JSON' do
          subject
          expect(json[:errors]).to include(
            {
              source: { pointer: '/data/attributes/title' },
              detail: "Title can't be blank"
            },
            {
              source: { pointer: '/data/attributes/content' },
              detail: "Content can't be blank"
            },
            {
              source: { pointer: '/data/attributes/slug' },
              detail: "Slug can't be blank"
            }
          )
        end
      end

      context 'when valid parameters provided' do
        let(:access_token) { create :access_token }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            data: {
              attributes: {
                title: 'Some title',
                content: 'Some content',
                slug: 'some-title'
              }
            }
          }
        end

        subject { post :create, params: valid_attributes}

        it 'should return 201 status' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should return proper JSON' do
          subject
          expect(json_data[:attributes]).to include(valid_attributes[:data][:attributes])
        end

        it 'should create the article' do
          expect { subject }.to change { Article.count }.by(1)
        end
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:article) { create :article, user: user }
    let(:access_token) { user.create_access_token }
    subject { patch :update, params: { id: article.id } }

    context 'when no authorization provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid authorization provided' do
      before { request.headers['authorization'] = 'invalid_token' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to update not owned article' do
      let(:other_user) { create :user }
      let(:other_article) { create :article, user: other_user }

      subject { patch :update, params: { id: other_article.id } }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'when invalid parameters provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end
        subject { patch :update, params: invalid_attributes.merge(id: article.id) }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error JSON' do
          subject
          expect(json[:errors]).to include(
            {
              source: { pointer: '/data/attributes/title' },
              detail: "Title can't be blank"
            },
            {
              source: { pointer: '/data/attributes/content' },
              detail: "Content can't be blank"
            }
          )
        end
      end

      context 'when valid parameters provided' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            data: {
              attributes: {
                title: 'Some title',
                content: 'Some content',
                slug: 'some-title'
              }
            }
          }
        end

        subject { patch :update, params: valid_attributes.merge(id: article.id) }

        it 'should return 201 status' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'should return proper JSON' do
          subject
          expect(json_data[:attributes]).to include(valid_attributes[:data][:attributes])
        end

        it 'should create the article' do
          subject
          expect(article.reload.title).to eq(valid_attributes[:data][:attributes][:title])
        end
      end
    end
  end
end
