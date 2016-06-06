#!/bin/sh
# chkconfig: 345 99 55
# description: script to start kewatcher
# /etc/init.d/kewatcher

#source functions library
. /etc/rc.d/init.d/functions

#source scheduler params
. /etc/sysconfig/deployed_application

start() {
  local program
  local options

  cd $ROOT_PATH

  echo "Starting KEWatcher"
  options="-m $KEWATCHER_MAX_WORKERS -c $KEWATCHER_REDIS_CONFIG -p $KEWATCHER_PIDFILE -v"
  program="source /home/$APP_USER/.bash_profile; RAILS_ENV=$RAILS_ENV bundle exec $ROOT_PATH/bin/kewatcher $options 2>&1 >> $KEWATCHER_LOGFILE"

  if [[ $APP_USER == $USER ]]
  then
    daemon --pidfile=$KEWATCHER_PIDFILE $program &
  else
    daemon --user $APP_USER --pidfile=$KEWATCHER_PIDFILE $program &
  fi
  RETVAL=$?

  if [ $RETVAL -eq 0 ]; then
    echo_success
  else
    echo_failure
  fi
  echo
}

stop() {
  echo "Stopping KEWatcher"

  if [ -f $KEWATCHER_PIDFILE ]; then
    kill -s QUIT $(cat $KEWATCHER_PIDFILE)
    RETVAL=$?
  else
    RETVAL=1
  fi

  if [ $RETVAL -eq 0 ]; then
    echo_success
    rm -f $KEWATCHER_PIDFILE
  else
    echo "Resque KEWatcher is not running"
    echo_failure
  fi
}

case "$1" in
  start) start ;;
  stop) stop ;;
  restart)
    echo "Restarting Resque KEWatcher ... "
    stop
    sleep 2
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit $?
