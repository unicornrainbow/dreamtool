# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Press::Application.load_tasks

# puts 'love'
# cljs = Rake::FileList.new("app/assets/clojurescript/**/*.cljs")
# puts cljs.ext('js')
# puts 'candy'
#
# task :compile_cljs do
#
# end
#
directory "public/assets/cljs/dreamtool/"
directory "tmp/cljs/src/dreamtool"


rule %r{public/assets/cljs/dreamtool/.+\.js$} =>
  [proc {|f| "tmp/cljs/out/dreamtool/" + File.basename(f)},
   "public/assets/cljs/dreamtool/"] do |t|
  cp t.source, t.name
end

rule %r{tmp/cljs/out/dreamtool/.+\.js$} =>
  proc {|f| "tmp/cljs/src/dreamtool/" + File.basename(f).sub('.js', '.cljs') } do |t|
  # proc {|f| f.sub('.js', '.cljs') } do |t|
  # cp t.source, t.name
  ns = "dreamtool." + File.basename(t.source, '.cljs').gsub('_', '-')
  sh "cd tmp/cljs; clj -m cljs.main --compile " + ns
end

rule %r{tmp/cljs/src/dreamtool/.+\.cljs$} =>
  [proc {|f| "app/assets/clojurescript/" + File.basename(f)},
   "tmp/cljs/src/dreamtool"] do |t|
  cp t.source, t.name
end

task :cljs =>
  ["public/assets/cljs/dreamtool/text_editor.js",
   "public/assets/cljs/dreamtool/text_editor.cljs.js",
   "public/assets/cljs/dreamtool/hello_world.js",
   "public/assets/cljs/dreamtool/hello_world.cljs.js"]



# This is a simple rule that copies the unmodified
# cljs to a public endpoint, mostly for development
rule %r{public/assets/cljs/dreamtool/.+\.cljs.js$} =>
  proc {|f| "app/assets/clojurescript/" + File.basename(f, '.js')}  do |t|
  cp t.source, t.name
end


# rule %r{tmp/cljs/src/dreamtool/.+\.js$} =>
#   proc {|f| f.sub('.js', '.cljs') } do |t|

# source = "app/assets/clojurescript/" + File.basename(t.name)


# rule "public/assets/cljs/dreamtool/*.js" =>
#   proc {|f| "tmp/cljs/src/dreamtool/" + File.basename(f) } do |t|
#   cp t.source, t.name
# end

# rule %r{tmp/cljs/src/dreamtool/.+\.js} =>
#   proc {|f| f.sub('.js', '.cljs') } do |t|
#   puts "yes!"
# end

# [proc {|f| "app/assets/clojurescript/" + File.basename(f) }] do |t|


# rule "tmp/cljs/src/dreamtool/text_editor.cljs" =>
#   "app/assets/clojurescript/text_editor.cljs" do |t|
#   cp t.source, t.name
# end



#  # =>
#   # "tmp/cljs/src/dreamtool/*.js"
#
# rule "tmp/cljs/src/dreamtool/*.cljs" =>
#   "app/assets/clojurescripts/*.cljs" do |t|
#   cp t.source, t.name
# end
#
#
# #   rsync -ru app/assets/clojurescript/ tmp/cljs/src/appname
# #   cd tmp/cljs/src/appname
# #   compile -d public/assets
# #
# # rake public/assets/cljs/text_editor.js
# #
# #
# # rake
