class FontsController < ApplicationController

  def index
    send_file 'data/fonts'
  end

end
