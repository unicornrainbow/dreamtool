class LineStreamer

  def initialize(paragraphs, options={})
    @paragraphs = paragraphs

    # Only supporting pixels for now, sorry.
    #@column_width = LinearMeasure.new(options[:width] || '273px')
    @column_width = LinearMeasure.new("#{options[:width]}px" || "225px")
    #raise "Units must be provided in pixels." unless @column_width.units == "px"

    @font_profile = options[:profile] || FontProfile.get('trykker')

    @paragraph_line_printers = @paragraphs.map { |p| ParagraphLinePrinter.new(p, @column_width, @font_profile, options) }

    @current_paragraph_line_printer = @paragraph_line_printers.shift
  end

  def take(line_count)
    output = StringIO.new

    while line_count > 0
      line_count -= @current_paragraph_line_printer.print(line_count, output)

      # Load next paragraph stream if needed.
      if @current_paragraph_line_printer.exhasusted?
        @current_paragraph_line_printer = @paragraph_line_printers.shift
        break unless @current_paragraph_line_printer
      end
    end


    output.string
  end

end
