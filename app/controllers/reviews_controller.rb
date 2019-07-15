class ReviewsController < ApplicationController

  # GET /reviews
  # url is a required query param
  def index
    url = params[:url] 
    # TODO: raise error if url not passed in

    url = 'https://www.lendingtree.com/reviews/personal/first-midwest-bank/52903183'
    @lender = Lender.new(url)

    render json: @lender.reviews
  end

end
