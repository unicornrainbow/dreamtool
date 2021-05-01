class ParagraphLinePrinter

  def initialize(paragraph, column_width, font_profiles, options = {})
    @paragraph    = paragraph
    @column_width = column_width
    @font_profiles = font_profiles

    @text = @paragraph.text # Just text for now.

    # Build stream
    #@children = @paragraph.children
    #@stream = make_stream(@children).flatten
    #@stream_length = @stream.count


    width = options[:width] || 284
    tolorence = options[:tolerence] || 10
    indent = options[:indent] || 40

    stream = Crawdad::HtmlTokenizer.new(FontProfile2.get('minion')).paragraph(@text, :hyphenation => true, indent: indent)
    para = Crawdad::Paragraph.new(stream, :width => width)
    @lines = para.lines(tolorence)

    @index = 0
    @continued = false # Indicates if paragraph has alreay been opened.
  end

  def make_stream(children)
    stream = children.map do |child|
      if child.text?
        child.text.chars
      else
        [
          {
            push: {
              tag_name: child.name,
              attributes: child.attributes
            }
          },
          make_stream(child.children),
          {
            pop: {
              tag_name: child.name
            }
          }
        ]
      end
    end
  end

  def next_character
    i = @index
    while i < @stream_length
      value = @stream[i+=1]
      return value if value.is_a? String
    end
  end

  def print(total_lines_to_print, output)
    lines = []

    while lines.count < total_lines_to_print
      line = get_next_line
      break unless line.present?
      lines << line
    end

    classes = ["typeset"]
    if @continued
      classes << "continued"
    else
      @continued = true
    end

    unless exhasusted?
      classes << "broken"
    end

    if classes.any?
      output.write "<p class=\"#{classes.join(' ')}\">#{lines.join}</p>"
    else
      output.write "<p>#{lines.join}</p>"
    end

    lines.count
  end

  def exhasusted?
    @index >= @lines.count
  end

  def get_next_line
    stringio = StringIO.new

    tokens, breakpoint = @lines[@index]
    stringio.write("<span class=\"line\">")

    # skip over glue and penalties at the beginning of each line
    tokens.shift until Crawdad::Tokens::Box === tokens.first

    tokens.each do |token|
      case token
      when Crawdad::Tokens::Box
        stringio.write(token.content)
      when Crawdad::Tokens::Glue
        stringio.write(" ")
      end
    end
    last_token = tokens.last
    if last_token.class == Crawdad::Tokens::Penalty && last_token[:flagged] == 1
      stringio.write("-")
    end
    stringio.write("</span> ")
    @index += 1
    stringio.string

    #@line ||= ColumnLine.new(@column_width, @font_profiles)
    #while current = @stream[@index]
      #case current
      #when String
        #if @line.add_character(current, next_character)
          #@index += 1
        #else
          #return @line.flush
        #end
      #when Hash
        #if current[:push]
          #@line.push_element(current[:push][:tag_name], current[:push][:attributes])
        #elsif current[:pop]
          #@line.pop_element
        #end
        #@index += 1
      #end
    #end
  rescue => e
    #debugger
    ""
  end

end
