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
    review.css('.reviewTitle').try(:text).try(:strip)
  end

  def parse_content(review)
    review.css('.reviewText').try(:text).try(:strip)
  end

  def parse_author(review)
    review.css('.consumerName').try(:text).try(:strip)
  end

  def parse_rating(review)
    # use regex to get first number in string
    review.css('.numRec').try(:text).try(:[], /\d/).try(:to_i) rescue 0 
  end

  def parse_date(review)
    # use regex to get month and year
    review.css('.consumerReviewDate').try(:text).try(:[], /Reviewed in (.*)/, 1) 
  end

end
