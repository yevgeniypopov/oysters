#!/bin/sh
# chkconfig: 345 99 55
# description: script to start kewatcher
# /etc/init.d/[application]_kewatcher

# source functions library
. /etc/rc.d/init.d/functions

# source application params
. /etc/sysconfig/deployed_application

start() {
  local program
  local options

  echo "Starting KEWatcher"
  if [ -e $KEWATCHER_PIDFILE ] && kill -0 `cat $KEWATCHER_PIDFILE` > /dev/null 2>&1; then
    echo_success
    return
  fi

  options="-m $KEWATCHER_MAX_WORKERS -c $KEWATCHER_REDIS_CONFIG -p $KEWATCHER_PIDFILE -v RAILS_ENV=$RAILS_ENV"

  su - $APP_USER -c "cd $ROOT_PATH; source /home/$APP_USER/.bash_profile; RAILS_ENV=$RAILS_ENV nohup bundle exec $ROOT_PATH/bin/kewatcher $options 2>&1 >> $KEWATCHER_LOGFILE &"

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
