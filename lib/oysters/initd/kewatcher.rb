require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :initd do

    namespace :kewatcher do
      desc 'Generate kewatcher init.d script'
      task :setup, roles: :app do
        run "mkdir -p #{shared_path}/config"
        location = File.expand_path('../../templates/kewatcher_init.sh.erb', __FILE__)
        config = ERB.new(File.read(location))
        put config.result(binding), "#{shared_path}/config/#{application}_kewatcher_init.sh"
      end

      desc 'Copy kewatcher into an init.d and adds to chkconfig'
      task :install, roles: :app do
        sudo "cp #{shared_path}/config/#{application}_kewatcher_init.sh /etc/init.d/#{application}_kewatcher;\
            sudo chmod +x /etc/init.d/#{application}_kewatcher;\
            sudo chkconfig --add #{application}_kewatcher", pty: true
      end

      desc 'Removes kewatcher from an init.d and deletes from chkconfig'
      task :uninstall, roles: :app do
        sudo "chkconfig --del #{application}_kewatcher;\
            sudo rm -f /etc/init.d/#{application}_kewatcher", pty: true
      end
    end

  end
end
