require 'oysters'

Oysters.with_configuration do

  namespace :resque do
    namespace :scheduler do
      task :start do
        run "cd #{current_path} && RAILS_ENV=#{rails_env} PIDFILE=#{current_path}/tmp/pids/scheduler.pid \
          BACKGROUND=yes VERBOSE=1 #{fetch(:bundle_cmd, 'bundle')} exec \
          rake resque:scheduler >/dev/null 2>&1 &"
      end

      task :stop do
        run "if [ -e #{current_path}/tmp/pids/scheduler.pid ]; then \
          #{try_sudo} kill -QUIT $(cat #{current_path}/tmp/pids/scheduler.pid) ; rm #{current_path}/tmp/pids/scheduler.pid \
        ;fi"
      end

      task :restart do
        stop
        sleep 5
        start
      end
    end
  end

end
