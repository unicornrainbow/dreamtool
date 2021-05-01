# Calls typesetting service to typeset html
class HtmlTypesetter
  LINEBREAK_SERVICE_URI = URI.parse(ENV['LINEBREAK_SERVICE_URL'])

  attr_reader :parsed_response, :typeset_html, :overrun_html, :width, :height, :overflow_reserve, :html, :line_height, :font_size

  def initialize(html, options={})
    @html             = html
    @options          = options
    @width            = options[:width]
    @height           = options[:height]
    @line_height      = options[:line_height]
    @font_size        = options[:font_size]
    @overflow_reserve = options[:overflow_reserve]
  end

  # Invokes service
  def typeset
    # Shortcut
    Rails.logger.debug "w #{width}"
    response = Net::HTTP.post_form(LINEBREAK_SERVICE_URI, {
      "width" => width.to_json, #width.to_json, #width,
      "height" => height,
      "line_height" => line_height,
      "font_size" =>     font_size,
      "overflow_reserve" => overflow_reserve,
      "html" => html
    })
    @parsed_response = JSON.parse(response.body)
    @typeset_html = @parsed_response["html"]
    @overrun_html = @parsed_response["overflow_html"]
  end

end
