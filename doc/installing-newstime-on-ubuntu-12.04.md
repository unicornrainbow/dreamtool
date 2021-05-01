### Installing Newstime on Ubuntu 12.04 ###

These are the recommended setup instructions of installing Newstime on Ubuntu
12.04 or other Linux like operating systems.


**Step 1)** Update your system to get the latest packages.

    sudo apt-get -y update

**Step 2)** Install packages which are used by Newstime.

    sudo apt-get install zlib1g zlib1g-dev
    sudo apt-get install build-essential
    sudo apt-get install openssl libssl-dev
    sudo apt-get install libmysqlclient18 libmysqlclient-dev
    sudo apt-get install libyaml-dev
    sudo apt-get install git-core
    sudo apt-get install python-software-properties
    sudo apt-get install libpq-dev
    sudo apt-get install nodejs
    sudo apt-get install mongodb

    # Need curl libraries install for curb gem in newstime project
    sudo apt-get install curl libcurl3 libcurl3-gnutls libcurl4-openssl-dev

    # Need the sqlite libraries
    sudo apt-get install sqlite3 libsqlite3-dev

    ## Install ImageMagik for paperclip
    sudo apt-get install imagemagick


**Step 3)** Install Rbenv for managing the ruby environment, and Ruby 2.0.0

See: https://github.com/sstephenson/rbenv#installation

**Step 4)** Install the bundler gem

    gem install bundler

**Step 5)** Clone the project, and run bundle to install dependencies

    mkdir -p /var/www
    cd /var/www
    git clone https://github.com/newstime/newstime.git
    cd newstime
    bundle

**Step 6)** Configure line breaking service URL

The following configuration is made in the .env file in the root of the project.
If this file does not exist, create it, and add the following line configured as
such.

    LINEBREAK_SERVICE_URL='http://localhost:9000'


**Step 7)** Start the application

    bundle exec script/start_unicorn

**Step 8)** Copy and setup nginx config

    sudo cp /var/www/newstime/config/example.nginx.conf /etc/nginx/sites-available/newstime.conf
    cd /etc/nginx/sites-enabled
    ln -d ../sites-available/newstime.conf
    sudo nginx -s reload

**Step 9)** Setup and start line breaking service.

    cd /var/www
    git clone https://github.com/newstime/line_breaking_service.git
    cd line_breaking_service
    bundle
    foreman start -p 9000
