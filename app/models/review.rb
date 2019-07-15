class Review
  attr_accessor :lender, :title, :content, :author, :rating, :date

  def initialize(lender, review)
    @lender = lender
    @title = parse_title(review)
    @content = parse_content(review)
    @author = parse_author(review)
    @rating = parse_rating(review)
    @date = parse_date(review)
  end

  def parse_title(review)
    review.css('.reviewTitle').text.try(:strip)
  end

  def parse_content(review)
    review.css('.reviewText').text.try(:strip)
  end

  def parse_author(review)
    review.css('.consumerName').text.try(:strip)
  end

  def parse_rating(review)
    # if not found, it will set to 0 which is O.K.
    review.css('.numRec').text.scan(/(\d) of \d/).flatten.first.to_i
  end

  def parse_date(review)
    review.css('.consumerReviewDate').text.scan(/Reviewed in (.*)/).flatten.first.try(:strip)
  end

#  def to_s
#    "Title: #{@title}"
  #end

end
