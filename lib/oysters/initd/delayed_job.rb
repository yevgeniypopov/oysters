require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :initd do
    namespace :delayed_job do
      desc 'Generate delayed_job init.d script'
      task :setup, roles: :app do
        run "mkdir -p #{shared_path}/config"
        location = File.expand_path('../../templates/delayed_job_init.sh.erb', __FILE__)
        config = ERB.new(File.read(location))
        text_config = config.result(binding)
        put text_config, "#{shared_path}/config/#{application}_delayed_job_init.sh"
      end

      desc 'Copy delayed_job into an init.d and add to chkconfig'
      task :install, roles: :app do
        sudo "cp #{shared_path}/config/#{application}_delayed_job_init.sh /etc/init.d/#{application}_delayed_job_#{rails_env};\
              sudo chmod +x /etc/init.d/#{application}_delayed_job_#{rails_env};\
              sudo chkconfig --add #{application}_delayed_job_#{rails_env}", pty: true
      end

      desc 'Removes delayed_job from an init.d and deletes from chkconfig'
      task :uninstall, roles: :app do
        sudo "chkconfig --del #{application}_delayed_job_#{rails_env};\
              sudo rm -f /etc/init.d/#{application}_delayed_job_#{rails_env}", pty: true
      end
    end
  end
end
