class ArticlesController < ApplicationController
  include Paginable

  skip_before_action :authorize!, only: %i[index show]

  def index
    paginated = paginate(Article.recent)
    render_collection(paginated)
  end

  def show
    render json: serializer.new(article)
  end

  def create
    article = current_user.articles.build(article_params)
    article.save!

    render json: serializer.new(article), status: :created
  rescue StandardError
    render json: ValidationSerializer.serialize(article.errors),
           status: :unprocessable_entity
  end

  def update
    user_article = current_user.articles.find(params[:id])
    user_article.update!(article_params)

    render json: serializer.new(user_article)
  rescue ActiveRecord::RecordNotFound
    authorization_error if article
  rescue StandardError
    render json: ValidationSerializer.serialize(user_article.errors),
           status: :unprocessable_entity
  end

  def destroy
    user_article = current_user.articles.find(params[:id])
    user_article.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    authorization_error if article
  end

  private

  def article_params
    params.require(:data).require(:attributes)
          .permit(:title, :content, :slug) ||
      ActionController::Parameters.new
  end

  def article
    Article.find(params[:id])
  end

  def serializer
    ArticleSerializer
  end
end
