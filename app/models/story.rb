class Story
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :body, type: String
  field :author, type: String
  field :source, type: String
  field :word_count, type: Integer

  alias :name :title

  before_save :count_words

  has_many :story_text_content_items, inverse_of: :story

  def count_words
    self.word_count = body.split(' ').count
  end


end
