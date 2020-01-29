class DevController < ApplicationController


  if Rails.env.development?
    # before_filter :localhost

  def edit
    # @tree = (getdirtree)

    tree = `tree -if`
    tree.split("\n")

    render 'text-editor', layout: false
  end

  def map
    Dir.chdir(File.join(Rails.root, 'app/controllers'))
    @controllers = Dir.glob('**/*.*')
    @controllers = @controllers.map { |c| [c, File.join("app/controllers", c)]}

    path = 'app/helpers'
    Dir.chdir(File.join(Rails.root, path))
    @helpers = Dir.glob('**/*.*')
        .map { |c| [c, File.join(path, c)]}
    render :map, layout: false
  end

  def tree
    # unless request.host == 'localhost' &&
    #   Rails.env.development?
    #   render "404", status: 404
    #   return nil
    # end

    path = params[:path]
    if params[:format]
      path << '.'
      path << params[:format]
    end

    path = path.gsub('..', '')
    fullpath = File.join(Rails.root, path)

    sauce = ERB::Util.html_escape \
      File.read fullpath

    # render text: params[:format]
    case params[:format]
    when 'js', 'coffee'

      Dir.chdir File.join(Rails.root,
                          'app/assets/javascripts')
      @mm = Dir.glob('**/*.*')

      sauce = sauce.lines.map do |line|
        case line
        when /(^.*)new ([\w\.]*)(.*)$/
          s,a,v = $1,$2,$3
          qrp = $2

          mqp = class2path $2, '.js.coffee'
          next line unless mqp

          # href = "/dev/browse/" + href
          # href = "/dev/tree/" + "app/assets/javascripts/" + m[0]
          href = "/dev/tree/" + "app/assets/javascripts/" + mqp
          # href.sub!("Newstime.","")
          # href = href.underscore
          # href = ""

          [s,"new ",
            "<a href=\"",href,"\">",
            a,"</a>",v,"\n"].join

        when /(^.*)extends ([\w\.\@]*)(.*)$/
          s,a,v = $1,$2,$3
          qrp = $2

          pqs = qrp.split('.')
          if /^@?(Dreamtool|Newstime|App)/.match pqs.first
            pqs.shift
          end
          tmr = pqs.join("/")
          udc = tmr.underscore
          m = @mm.select { |f|
            /^#{udc}\.js(\.coffee)/.match File.basename(f) }

          if m.count > 1
            # next line
            render text: m
            return
            raise "#{udc} had more than one matching file"
          end

          if m.count == 0
            if pqs.first == "Backbone"
              # m = ["lib/backbone.js"]
              href = "http://www.backbonejs.org/"
              if pqs[1]
                href += "#" +pqs[1]
              end
            else
              next line
              # render text: mm
              # return
              raise "%s had no matches" % udc
            end
          end

          # href = "/dev/browse/" + href
          href ||= "/dev/tree/" + "app/assets/javascripts/" + m[0]

          [s,"extends ",
            "<a href=\"",href,"\">",
            a,"</a>",v,"\n"].join
        else
          line
        end
      end.join
    when 'rb'

    end


    render text: "<pre>#{sauce}</pre>"
  end

  def browse
    path = params[:path]
    if params[:format]
      path = params[:format]
    end
    d = path.underscore
    # render text: d
    # return
    # href.sub!("Newstime.","")
    # href = href.underscore
    # href = ""

    # render text: `ls -R #{File.join(Rails.root, 'app/assets/javascripts')}`
    Dir.chdir(File.join(Rails.root, 'app/assets/javascripts'))
    k = Dir.glob('**/*.*').select {|f| /#{d}/.match File.basename(f) }

    @files = k.map do |filepath|
      [filepath.split("/").last, filepath]
    end
    render :browse, layout: false
    # render text: "#{k}<BR><pre>#{sauce}</pre>"

  end

  private

  def class2path kls, ext

    pqs = kls.split('.')

    if /^@?(Dreamtool|Newstime|App)/.match pqs.first
      pqs.shift
    end
    tmr = pqs.join("/")
    udc = tmr.underscore
    m = @mm.select { |f|
      /^#{udc}\.js(\.coffee)/.match File.basename(f) }

    if m.count > 1
      # next line
      # return false
      render text: m
      return
      raise "#{udc} had more than one matching file"
    end

    if m.count == 0
      return false
      # next line
      # render text: mm
      # return
      raise "%s had no matches" % udc
    end

    return m[0]
  end

  def localhost
    return request.host == 'localhost'
    # unless
      # Rails.env.development?
      # render "404", status: 404
      # return false
    # end
  end

  # def filter_out test
  #   before_filter do
  #     unless send(test)
  #       render "404", status: 404
  #       return false
  #     end
  #   end
  # end
  #
  # before_filter :localhost

  end

end
