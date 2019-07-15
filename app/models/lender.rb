require 'nokogiri'
require 'open-uri'
require 'openssl'

class Lender
  attr_accessor :url, :name, :type, :rating, :review_count, :reviews

  def initialize(url)
    @url = url
    @doc = Nokogiri::HTML(open(@url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE))

    @name = parse_name
    @type = parse_type
    @rating = parse_rating
    @review_count = parse_review_count
    @reviews = collect_reviews
  end

  def parse_name
    @doc.css('.lenderInfo > h1').text.try(:strip)
  end

  def parse_type
    @doc.css('.lenderInfo > h1').text.try(:strip)
  end

  def parse_rating
    @doc.css('.mainRating > p').text.scan(/.* of \w/).try(:first).try(:strip)
  end

  def parse_review_count
    @doc.css('.mainRating > p').text.scan(/.* of \w (.*) Reviews/).flatten.try(:first).to_i
  end

  def collect_reviews
    reviews = []

    reviews_raw = @doc.css('.mainReviews')
    reviews_raw.each do |review|
      reviews << Review.new(@name, review)
    end

    reviews
  end
end
