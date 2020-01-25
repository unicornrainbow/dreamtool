class DevController < ApplicationController


  if Rails.env.development?
    # before_filter :localhost

  def edit
    # @tree = (getdirtree)

    tree = `tree -if`
    tree.split("\n")

    render 'text-editor', layout: false
  end

  def tree
    path = params[:path]

    if params[:format]
      path << '.'
      path << params[:format]
    end

    path = path.gsub('..', '')

    fullpath = File.join(Rails.root, path)

    send_file fullpath
    # render text: `cat #{fullpath}`
  end

  def tree
    unless request.host == 'localhost' &&
      Rails.env.development?
      render "404", status: 404
      return nil
    end

    path = params[:path]

    if params[:format]
      path << '.'
      path << params[:format]
    end

    path = path.gsub('..', '')


    fullpath = File.join(Rails.root, path)

    sauce = File.read fullpath
    sauce = sauce.lines.map do |line|
      if line =~ /(^.*)new ([\w\.]*)(.*)$/
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
    k = Dir.glob('**/*.*').select {|f| /#{d}/.match f }

    @files = k.map do |filepath|
      [filepath.split("/").last, filepath]
    end
    render :browse, layout: false
    # render text: "#{k}<BR><pre>#{sauce}</pre>"

  end

  private

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
