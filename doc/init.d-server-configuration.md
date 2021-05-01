### Init.d Server Configuration ###

This document conver init.d server configuration, in order to automatically
start with the operation system with Ubuntu 12.04.

## Init.d for Line Break Service

This is an example configuration for setting up the line break service with
init.d.

Paste contents into a file named /etc/init.d/linebreak_service

    #!/bin/bash
    ### BEGIN INIT INFO
    # Provides:          Line Break Service
    # Required-Start:    $local_fs $remote_fs $network $syslog
    # Required-Stop:     $network $local_fs $syslog
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Start the linebreak service at boot
    # Description:       Enable linebreak service at boot time.
    ### END INIT INFO

    set -u
    set -e

    PATH=/usr/local/ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

    case $1 in
    start)
            cd /var/www/linebreak-demo.newstime.io
      script/wake_giant
      ;;
    stop)
            cd /var/www/linebreak-demo.newstime.io
      script/slay_giant
      ;;
    esac

Change premission on file to be executable

    sudo chmod +x /etc/init.d/linebreak_service

#### Use update-rc.d to register to come up on system start up

    sudo update-rc.d linebreak_service defaults
    sudo update-rc.d linebreak_service enable

#### Starting and stopping the service

    sudo /etc/init.d/linebreak_service stop
    sudo /etc/init.d/linebreak_service start


## Init.d for Unicorn Application, like Newstime

Paste the following into a file and save to /etc/init.d/unicorn

    #!/bin/sh

    ### BEGIN INIT INFO
    # Provides:          unicorn
    # Required-Start:    $local_fs $remote_fs $network $syslog
    # Required-Stop:     $network $local_fs $syslog
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Start unicorn at boot time.
    # Description:       Enable unicorn at boot time.
    ### END INIT INFO

    # init.d script for single or multiple unicorn installations. Expects at least one .conf
    # file in /etc/unicorn
    #
    # Modified by jay@gooby.org http://github.com/jaygooby
    # based on http://gist.github.com/308216 by http://github.com/mguterl
    #
    ## A sample /etc/unicorn/my_app.conf
    ##
    ## RAILS_ENV=production
    ## RAILS_ROOT=/var/apps/www/my_app/current
    #
    # This configures a unicorn master for your app at /var/apps/www/my_app/current running in
    # production mode. It will read config/unicorn.rb for further set up.
    #
    # You should ensure different ports or sockets are set in each config/unicorn.rb if
    # you are running more than one master concurrently.
    #
    # If you call this script without any config parameters, it will attempt to run the
    # init command for all your unicorn configurations listed in /etc/unicorn/*.conf
    #
    # /etc/init.d/unicorn start # starts all unicorns
    #
    # If you specify a particular config, it will only operate on that one
    #
    # /etc/init.d/unicorn start /etc/unicorn/my_app.conf

    PATH=/usr/local/ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

    set -e
    set -x

    sig () {
      test -s "$PID" && kill -$1 `cat "$PID"`
    }

    oldsig () {
      test -s "$OLD_PID" && kill -$1 `cat "$OLD_PID"`
    }

    cmd () {

      case $1 in
        start)
          sig 0 && echo >&2 "Already running" && exit 0
          echo "Starting"
          $CMD
          ;;
        stop)
          sig QUIT && echo "Stopping" && exit 0
          echo >&2 "Not running"
          ;;
        force-stop)
          sig TERM && echo "Forcing a stop" && exit 0
          echo >&2 "Not running"
          ;;
        restart|reload)
          sig USR2 && sleep 5 && oldsig QUIT && echo "Killing old master" `cat $OLD_PID` && exit 0
          echo >&2 "Couldn't reload, starting '$CMD' instead"
          $CMD
          ;;
        upgrade)
          sig USR2 && echo Upgraded && exit 0
          echo >&2 "Couldn't upgrade, starting '$CMD' instead"
          $CMD
          ;;
        rotate)
                sig USR1 && echo rotated logs OK && exit 0
                echo >&2 "Couldn't rotate logs" && exit 1
                ;;
        *)
          echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
          exit 1
          ;;
        esac
    }

    setup () {

      echo -n "$RAILS_ROOT: "
      cd $RAILS_ROOT || exit 1
      export PID=$RAILS_ROOT/tmp/pids/unicorn.pid
      export OLD_PID="$PID.oldbin"

      CMD="bundle exec unicorn -c config/unicorn.rb -E $RAILS_ENV -D"
    }

    start_stop () {

      # either run the start/stop/reload/etc command for every config under /etc/unicorn
      # or just do it for a specific one

      # $1 contains the start/stop/etc command
      # $2 if it exists, should be the specific config we want to act on
      if [ $2 ]; then
        . $2
        setup
        cmd $1
      else
        for CONFIG in /etc/unicorn/*.conf; do
          # import the variables
          . $CONFIG
          setup

          # run the start/stop/etc command
          cmd $1
        done
       fi
    }

    ARGS="$1 $2"
    start_stop $ARGS


Update the permissions and register to be started on boot


    sudo chmod +x /etc/init.d/unicorn

    sudo update-rc.d unicorn defaults
    sudo update-rc.d unicorn enable

Add configuration files to /etc/unicorn to for each app. For example, for the
press, if the application files were at /var/www/press

File: /etc/unicorn/press.conf

    RAILS_ENV=production
    RAILS_ROOT=/var/www/press

And to start/stop manually

    sudo /etc/init.d/unicorn start /etc/unicorn/press.conf
    sudo /etc/init.d/unicorn stop /etc/unicorn/press.conf
