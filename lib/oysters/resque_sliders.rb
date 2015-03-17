require 'oysters'

Oysters.with_configuration do

  namespace :resque do
    namespace :kewatcher do
      desc 'Starts kewatcher'
      task :start do
        command = %Q%
          if [ -e #{shared_path}/pids/kewatcher.pid ] && kill -0 `cat #{shared_path}/pids/kewatcher.pid` >/dev/null 2>&1; then
            echo "Kewatcher is already running. Sending restart command...";
            kill -s HUP `cat #{shared_path}/pids/kewatcher.pid`;
          else
            echo "Kewatcher is not running. Executing start command...";
            cd #{current_path};
            RAILS_ENV=#{rails_env} #{fetch(:bundle_cmd, "bundle")} exec \
              #{current_path}/bin/kewatcher \
                -m #{fetch(:kewatcher_max_workers, 30)} \
                -c #{current_path}/config/redis.yml \
                -p #{shared_path}/pids/kewatcher.pid \
              >/dev/null 2>&1 &
            tries_count=10;
            success=0;
            while [ $((tries_count-=1)) -ge 0 ]; do
              if [[ -n `pgrep -xf "[K]EWatcher.*"` ]] >/dev/null 2>&1; then
                success=1;
                break;
              fi;
              sleep 1;
            done;
            if [ $success -eq 0 ]; then
              echo "***KEWatcher has failed to start. Please try again...";
            else
              echo "+++KEWatcher has been started successfully.";
            fi;
          fi;
        %

        run command
      end

      desc 'Stops kewatcher'
      task :stop do
        command = %Q%
          if [ -e #{shared_path}/pids/kewatcher.pid ] && kill -0 `cat #{shared_path}/pids/kewatcher.pid` >/dev/null 2>&1; then
            echo "Stopping Kewatcher...";
            kill -s QUIT `cat #{shared_path}/pids/kewatcher.pid`;
            tries_count=50;
            success=0;
            while [ $((tries_count-=1)) -ge 0 ]; do
              if [[ -n `pgrep -xf "[K]EWatcher.*|[r]esque-[0-9]+.*"` ]] >/dev/null 2>&1; then
                sleep 1;
              else
                success=1;
                break;
              fi;
            done;
            if [ $success -eq 0 ]; then
              pidkewat=`pgrep -xf [K]EWatcher.*`;
              if [[ -n $pidkewat ]] >/dev/null 2>&1; then
                echo "~~~KEWatcher has failed to stop. So kill pid=$pidkewat ...";
                kill -s KILL `cat #{shared_path}/pids/kewatcher.pid`;
                rm -f #{shared_path}/pids/kewatcher.pid;
                echo "~~~ killing workers as well ...";
                kill -s KILL `pgrep -xf "[r]esque-[0-9]+.*" | xargs`;
              else
                echo "***KEWatcher has been stopped. But some workers still running. Kill'em all...";
                kill -s KILL `pgrep -xf "[r]esque-[0-9]+.*" | xargs`;
              fi;
            else
              echo "+++KEWatcher has been stopped successfully.";
            fi;
            sleep 1;
          else
            echo "Kewatcher is not running.";
          fi;
        %

        run command
      end

      desc 'Restarts kewatcher'
      task :restart do
        #command = %Q%
        #  if [ -e #{shared_path}/pids/kewatcher.pid ] && kill -0 `cat #{shared_path}/pids/kewatcher.pid` > /dev/null 2>&1; then
        #    echo "Kewatcher is running. Sending restart signal...";
        #    kill -s HUP `cat #{shared_path}/pids/kewatcher.pid`;
        #  else
        #    echo "Kewatcher is not running. Executing start command...";
        #    cd #{current_path}; RAILS_ENV=#{rails_env} #{fetch(:bundle_cmd, "bundle")} exec kewatcher -m #{fetch(:kewatcher_max_workers, 130)} -c #{current_path}/config/redis.yml -p #{shared_path}/pids/kewatcher.pid >/dev/null 2>&1 &
        #  fi;
        #%
        #
        #run command
        stop; start
      end
    end

    namespace :sliders do
      desc 'Setup resque sliders'
      task :setup do
        command = %Q%
          echo "Setting up resque sliders...";
          cd #{current_path}; RAILS_ENV=#{rails_env} #{fetch(:bundle_cmd, "bundle")} exec rake resque:setup_resque_slider >/dev/null 2>&1 &
        %

        run command
      end
    end
  end

end
