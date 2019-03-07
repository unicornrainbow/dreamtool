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
end
