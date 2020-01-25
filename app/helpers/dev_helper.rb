module DevHelper
  def read_file(path)
    sauce = html_escape File.read path
    # sauce = File.read File.join(Rails.root, 'app/assets/javascripts', k.last)
    sauce = sauce.lines.map do |line|
      case line
      when /(^.*)new ([\w\.]*)(.*)$/
        s,a,v = $1,$2,$3
        href = $2
        href = "/dev/browse/" + href
        # href.sub!("Newstime.","")
        # href = href.underscore
        # href = ""

        "->" + [s,"new ",
          "<a href=\"",href,"\">",
          a,"</a>",v,"\n"].join
      else
        line
      end
    end.join
  end
end
