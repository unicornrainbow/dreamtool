## Installation

This is the recommended installation procedure for Newstime, based on Ubuntu
12.04.

Step 1) Once connected and logged into the box Newstime will be installed on, be
sure to do an apt-get update, to ensure you are working with the latest
recommended packages.

    sudo apt-get -y update

Step 2) Install system packages.

    sudo apt-get install zlib1g zlib1g-dev build-essential openssl libssl-dev \
      libmysqlclient18 libmysqlclient-dev libyaml-dev curl git-core python-software-properties libpq-dev nodejs

    # Need curl libraries install for curb gem in newstime project
    sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev

    # Need the sqlite libraries
    sudo apt-get install sqlite3 libsqlite3-dev

    ## Install ImageMagik for paperclip
    sudo apt-get install imagemagick


Step 3) Rbenv, and ruby





--- Work In Progress, Install Notes Below ---

# Install Ruby Gems
sudo apt-get install -y rubygems

# Install bundler
sudo gem install bundler

# Ran into an issue getting newstime compile the debugger, running this first
# fixed the issue. Source: http://stackoverflow.com/a/23857724
#sudo gem install debugger-ruby_core_source

#mkdir -p /var/www
#cd /var/www
#git clone https://github.com/newstime/newstime.git
#cd newstime
#bundle

# Create pid and socket folders for unicorn
#mkdir -p /home/vagrant/newstime/tmp/pids/
#mkdir -p /home/vagrant/newstime/tmp/sockets

#Start the application
# bundle exec script/start_unicorn

# Copy and setup nginx config
# sudo cp /var/www/newstime/config/example.nginx.conf /etc/nginx/sites-available/newstime.conf
# cd /etc/nginx/sites-enabled
# ln -d ../sites-available/newstime.conf
# sudo nginx -s reload

# did a mongorestore fromt the /vagrant linked folder after comming a mongodump
# there from my system.

# Needed to clone down the sfrecord media module to get things started
# mkdir -p /home/vagrant/layouts
# cd /home/vagrant/layouts
#git clone https://github.com/newstime/sfrecord_layout.git sfrecord

# Test images



# Copy the nginx configuration file.
# Link the nginx configuration file
# Restart nginx
# Clone the line break service
#git clone https://github.com/newstime/line_breaking_service.git
#cd line_breaking_service
#bundle
# Bundle the linke break service
# Start the link break service with foreman

# Configure all the services the come up with init.d

#rake db:create

# Start the web application

# Also need background services and stuff...



# Incorporating instuctions from https://help.ubuntu.com/community/RubyOnRails#Installing_RubyGems

## Install Rails using rubygems
#sudo gem install rails
