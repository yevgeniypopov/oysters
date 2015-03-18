require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :initd do

    namespace :unicorn do
      desc 'Generate unicorn init.d script'
      task :setup, roles: :app do
        su_command = "su - #{user} -c"
        CapistranoUnicorn::Config.load self
        CapistranoUnicorn::Utility.send(:alias_method, :old_try_unicorn_user, :try_unicorn_user)
        CapistranoUnicorn::Utility.send(:define_method, :try_unicorn_user, Proc.new { su_command })
        run "mkdir -p #{shared_path}/config"
        location = File.expand_path('../../templates/unicorn_init.sh.erb', __FILE__)
        config = ERB.new(File.read(location))
        text_config = config.result(binding)
        text_config.gsub!(/(#{su_command}) (.*);/,'\1 "\2";')
        put text_config, "#{shared_path}/config/#{application}_unicorn_init.sh"
        CapistranoUnicorn::Utility.send(:alias_method, :try_unicorn_user, :old_try_unicorn_user)
      end

      desc 'Copy unicorn into an init.d and add to chkconfig'
      task :install, roles: :app do
        sudo "cp #{shared_path}/config/#{application}_unicorn_init.sh /etc/init.d/#{application}_unicorn_#{rails_env};\
              sudo chmod +x /etc/init.d/#{application}_unicorn_#{rails_env};\
              sudo chkconfig --add #{application}_unicorn_#{rails_env}", pty: true
      end

      desc 'Removes unicorn from an init.d and deletes from chkconfig'
      task :uninstall, roles: :app do
        sudo "chkconfig --del #{application}_unicorn_#{rails_env};\
              sudo rm -f /etc/init.d/#{application}_unicorn_#{rails_env}", pty: true
      end
    end

  end
end
