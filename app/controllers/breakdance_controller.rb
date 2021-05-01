require 'net/http'  # http://ruby-doc.org/stdlib-2.3.0/libdoc/net/http/rdoc/Net/HTTP.html

class BreakdanceController < ApplicationController

  def info
    breakdance_url = ENV['LINEBREAK_SERVICE_URL']

    # Detect is breakdance is responding.
    uri = URI(breakdance_url)
    res = Net::HTTP.get_response(uri)

    power = res.code == '200' ? 'On' : 'Off'

    render text: "#{breakdance_url} #{power}", content_type: 'text'
  end

end
