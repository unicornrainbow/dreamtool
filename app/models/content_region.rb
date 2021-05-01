#class ContentRegion
  #include Mongoid::Document
  #include Mongoid::Timestamps

  #field      :column_width,  type: Integer  # Number of columns wide (Could probably have better name, like column_count)
  ## Which row is the contnet region on.
  #field      :row_sequence,  type: Integer, default: 1
  #field      :sequence,      type: Integer

  #belongs_to :organization
  #belongs_to :page
  #has_many :content_items, :inverse_of => :content_region, order: :sequence.asc

  #def next_content_item_sequence
    #(content_items.max(:sequence) || 0) + 1
  #end

  #def resequence_content_items!
    ## NOOP for now...
    ##content_items.asc(:sequence).each_with_index do |content_item, i|
      ##content_items.update_attribute(:sequence, i+1) if content_item.sequence != i+1
    ##end
  #end

  ## Return the pixel width of the content region
  #def width
    #width_of_column = 34 # Standin values. These should come from somewhere
    #width_of_gutter = 16
    #(column_width * width_of_column) + (column_width - 1) * width_of_gutter
  #end

#end
