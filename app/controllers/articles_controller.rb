class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    session[:page_views] ||= 0
    session[:page_views] += 1

    unless session[:page_views] <= 3
      exceeded_view_limit
      return
    end

    article = Article.find(params[:id])
    render json: article
  end

  private

  def exceeded_view_limit
    render json: { error: 'You have exceeded your number of free articles.' }, status: :unauthorized
  end

  def record_not_found
    render json: { error: 'Article not found' }, status: :not_found
  end

end
