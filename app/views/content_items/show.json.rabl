object @content_item

# Content Item Base Attributes
attributes *%w(
  sequence
  height
  font_size
  rendered_html
  overrun_html
)

# Story Text Attributes
attributes :columns

# Photo Attributes
attributes :photo

#node :rendered_content_item do
  #raw render_content_item @content_item
#end
