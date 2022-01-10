class CommentsController < ApplicationController
  include Paginable

  skip_before_action :authorize!, only: [:index]
  before_action :load_article

  def index
    paginated = paginate(@article.comments)
    render_collection(paginated)
  end

  def create
    @comment = @article.comments.build(comment_params.merge(user: current_user))
    @comment.save!

    render json: serializer.new(@comment), status: :created
  rescue StandardError
    render json: ValidationSerializer.serialize(@comment.errors),
           status: :unprocessable_entity
  end

  private

  def load_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:data).require(:attributes).permit(:content)
  end

  def serializer
    CommentSerializer
  end
end
