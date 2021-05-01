class HeadlineContentItem < ContentItem
  field :text, type: String
  field :font_size, type: String
  field :font_weight, type: String
  field :font_family
  field :font_style
  field :text_align
  field :color
  field 'margin-top'
  field 'margin-bottom'
  field 'margin-right'
  field 'margin-left'

  def style
    attributes.slice('font_size', 'font_weight', 'font_family', 'font_style', 'text_align', 'margin-top', 'margin-bottom', 'margin-left', 'margin-right').map do |k, v|
      "#{k.gsub('_', '-')}: #{v};"
    end.join
  end

end
