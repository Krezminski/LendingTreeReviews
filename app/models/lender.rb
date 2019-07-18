require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'uri'

class Lender
  attr_accessor :url, :name, :type, :rating, :review_count, :reviews

  def initialize(url)
    @base_url = URI.parse(url)
    raise URI::InvalidURIError unless @base_url.to_s =~ URI::regexp

    @current_page = 1
    @main_doc = get_doc(@base_url)

    @name = parse_name
    @type = parse_type
    @rating = parse_rating
    @review_count = parse_review_count

    cache_key = "#{@name}-#{@review_count}"
    @reviews = Rails.cache.fetch(cache_key, expires_in: 1.day) do
      collect_reviews
    end
    @reviews_collected = reviews.count
  end

  def parse_name
    @main_doc.css('.lenderInfo > h1').try(:text).try(:strip)
  end

  def parse_type
    # lender type is in url: lendingtree.com/reviews/#type/#Lender-name
    @base_url.to_s[/com\/reviews\/(\w+)\//, 1].try(:strip).try(:capitalize)
  end

  def parse_rating
    # text will be of form: '5.0 of 5 817 Reviews'
    @main_doc.css('.mainRating > p').try(:text).try(:[], /\d\.\d/) 
  end

  def parse_review_count
    # text will be of form: '5.0 of 5 817 Reviews'
    @main_doc.css('.mainRating > p').try(:text).try(:[], /.* of \d (\d+)/, 1) 
  end

  def collect_reviews
    reviews = []

    doc = @main_doc
    reviews_raw = get_reviews(doc)

    while(reviews_raw.try(:length) && reviews_raw.length > 0)
      reviews_raw.each do |review|
        reviews << Review.new(@name, review)
      end
      doc = get_next_page
      reviews_raw = get_reviews(doc)
    end

    reviews
  end

  def get_doc(url)
    Nokogiri::HTML(open(url.to_s, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))
  end

  def get_reviews(doc)
    doc.css('.mainReviews')
  end

  def build_url(url, page)
    uri = URI(url)
    # add page number to query params
    uri.query = URI.encode_www_form([["pid", page]])
    uri.to_s
  end

  def get_next_page
    @current_page += 1
    next_url = build_url(@base_url.to_s, @current_page)
    get_doc(next_url)
  end
  
  def to_h
    {
      "Name": @name,
      "Lender Type": @type,
      "Overall Rating": @rating,
      "Total Review Count": @review_count,
      "Reviews Collected": @reviews_collected,
      "Reviews": @reviews
    }
  end
end
