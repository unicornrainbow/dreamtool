module Notebox
  class Entry
    include Mongoid::Document
    field :title
    field :url
    field :description
    field :created_at, type: DateTime

    field :path
    field :markdown
    field :html
    field :created_at
    field :formatted_date
    field :formatted_time
    field :formatted_date_time
    field :title

    def initialize
    end

    #def delete_me
      #{
        #path: path,
        #markdown: markdown,
        #html: html,
        #created_at: created_at,
        #formatted_date: created_at.strftime('%A, %B %e %Y'),
        #formatted_time: created_at.strftime('%I:%M %p'),
        #formatted_date_time: created_at.strftime('%A, %B %e, %Y, %l:%M %p'),
        #title: title
      #}
    #end

  end
end
