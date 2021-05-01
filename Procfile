web: bundle exec unicorn -p $PORT -c ./config/heroku-unicorn.rb
worker: bundle exec sidekiq
faye: bundle exec rackup faye.ru -s thin -E production
