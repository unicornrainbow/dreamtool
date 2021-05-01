class WIPWorker
  include Sidekiq::Worker

  def perform(edition_id)
    edition = Edition.find(edition_id)

    screenname = edition.user ? edition.user.screenname : 'nobody'
    disk_path = "#{Rails.root}/share/#{screenname}/#{edition.id.to_s[0..7]}"
    system "mkdir -p '#{disk_path}'"

    case `uname`.strip
    when 'Darwin' # OSX
      system "cd \"#{disk_path}\"; webkit2png -z 1.0 -C -s 1 --filename=wip --clipwidth=800 --clipheight=900 http://localhost:9494/editions/#{edition.id.to_s}/preview/main.html; mv wip-clipped.png wip.png"
      system "cd \"#{disk_path}\"; convert wip.png -resize 800x900 wip.png"
    when 'Linux'  # Ubuntu
      system "cd #{disk_path}; webkit2png -x 1400 900 -g 1400 900 --aspect-ratio=crop -o wip.png http://www.newstime.love/editions/#{edition.id.to_s}/preview/main.html"
      system "cd #{disk_path}; convert wip.png -resize 1024x1024 wip.png"
    end
  end

end
