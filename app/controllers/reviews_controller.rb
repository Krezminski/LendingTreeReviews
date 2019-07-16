class ReviewsController < ApplicationController

  # GET /reviews
  # url is a required query param
  def index
    url = params[:url] 

    @lender = Lender.new(url)

    render json: @lender.to_h
  rescue URI::InvalidURIError => e
    render json: { error: "Param 'url' must be a valid url: #{url}" }
  rescue StandardError => e
    render json: { error: e.to_s }
  end

end
