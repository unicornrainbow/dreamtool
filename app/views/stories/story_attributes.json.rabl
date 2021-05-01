object @story
attributes :name

node do |story|
  {
    url: url_for(story)
  }
end
