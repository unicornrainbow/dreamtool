class DevController < ApplicationController
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

  def browse
    # local only
    unless Rails.env.development?
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
        href.sub!("Newstime.","")
        href = href.underscore
        href = ""

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
    # local only
    unless request.host == 'localhost'
      render "404", status: 404
      return nil
    end

    path = params[:path]

    # render text: `ls -R #{File.join(Rails.root, 'app/assets/javascripts')}`
    Dir.chdir(File.join(Rails.root, 'app/assets/javascripts'))
    Dir.glob('*').select {|f| //.match f }

  end
end
