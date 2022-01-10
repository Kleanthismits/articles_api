require 'rails_helper'

RSpec.describe '/comments', type: :request do
  let(:article) { create :article}

  describe 'GET /index' do
    subject { get "/articles/#{article.id}/comments" }
    it 'renders a successful response' do
      subject
      expect(response).to be_successful
    end

    it 'should return only articles belonging to article' do
      comment = create :comment, article: article
      create :comment

      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first['id']).to eq(comment.id.to_s)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article

      subject
      expect(json_data.first['attributes']).to eq(
        { 'content' => comment.content }
      )
    end

    it 'should have related object in the response' do
      user = create :user
      create :comment, article: article, user: user

      subject
      relationships = json_data.first['relationships']
      expect(relationships['article']['data']['id']).to eq article.id.to_s
      expect(relationships['user']['data']['id']).to eq user.id.to_s
    end

    it 'should paginate results' do
      comments = create_list :comment, 3, article: article
      get "/articles/#{article.id}/comments", params: { page: { number: 2, size: 1 } }

      expect(json_data.length).to eq(1)
      comment = comments.second
      expect(json_data.first['id']).to eq(comment.id.to_s)
    end
  end

  describe 'POST /create' do
    let(:user) { create :user }
    let(:access_token) { user.create_access_token }
    let(:valid_headers) { { Authorization: "Bearer #{access_token.token}" } }

    context 'with valid parameters' do
      context 'when no authorization provided' do
        before { post "/articles/#{article.id}/comments" }
        it_behaves_like 'forbidden_requests'
      end

      context 'when invalid authorization provided' do
        let(:invalid_headers) { { 'Authorization' => 'invalid_token' } }

        before { post "/articles/#{article.id}/comments", headers: invalid_headers }
        it_behaves_like 'forbidden_requests'
      end

      context 'when authorized' do
        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'content' => 'Some content',
                'user_id' => user.id,
                'article_id' => article.id
              }
            },
            'article_id' => article.id
          }
        end

        subject do
          post "/articles/#{article.id}/comments",
               params: valid_attributes,
               headers: valid_headers
        end

        it 'should return 201 status' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'creates a new Comment' do
          expect { subject }.to change(article.comments, :count).by(1)
        end

        it 'renders a JSON response with the new comment' do
          subject
          expect(json_data['attributes']).to eq(
            {
              'content' => 'Some content'
            }
          )
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        {
          'data' => {
            'attributes' => {
              'content' => ''
            }
          }
        }
      end

      subject do
        post "/articles/#{article.id}/comments",
             params: invalid_attributes,
             headers: valid_headers
      end

      it 'should return 422 status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new Comment' do
        expect { subject }.to change(Comment, :count).by(0)
      end

      it 'renders a JSON response with errors for the new comment' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/content' },
            'detail' => "Content can't be blank"
          }
        )
      end
    end
  end
end
