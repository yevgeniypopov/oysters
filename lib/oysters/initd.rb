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
        location = File.expand_path('../templates/unicorn_init.sh.erb', __FILE__)
        config = ERB.new(File.read(location))
        puts config.result(binding)
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

    set :ntp_host, 'pool.ntp.org' unless exists?(:ntp_host)

    namespace :ntp do
      desc 'Installs and configures ntp service'
      task :install do
        sudo "yum install -y ntp;\
              sudo chkconfig ntpd on;\
              sudo service ntpd stop;\
              sleep 3;\
              if [[ ! `grep 'server #{ntp_host}' /etc/ntp.conf` ]];
              then
                  sudo sed -i '0,/^server /s//server #{ntp_host}\n&/' /etc/ntp.conf;\
              fi;\
              if [[ ! `grep '#{ntp_host}' /etc/ntp/step-tickers` ]];
              then
                  sudo sed -i '0,/^#.*$/s//&\n#{ntp_host}/' /etc/ntp/step-tickers;\
              fi;\
              sudo ntpdate #{ntp_host};\
              sleep 1;\
              sudo service ntpd start;
        "
      end
    end

    INITD_SERVICES = %w(nginx memcached redis unicorn thin god mysql postgres)
    set :initd_services, INITD_SERVICES unless exists?(:initd_services)

    desc "Check if all needed services are enabled to run on system start-up"
    task :check do
      services_str = initd_services.join('|')
      results = capture("/sbin/chkconfig --list | egrep '#{services_str}'").split("\n")

      results.each do |result|
        service_name = result.match(/\S+/)[0]

        print "Checking #{service_name}... "
        if result =~ /3:on/ && result =~ /4:on/ && result =~ /5:on/
          puts 'OK'
        else
          puts 'Failed! Fixing...'
          sudo "/sbin/chkconfig --level 345 #{service_name} on"
        end

        puts "\n"
      end

      puts 'Done!'
    end

    namespace :kewatcher do
      desc 'Generate kewatcher init.d script'
      task :setup, roles: :app do
        run "mkdir -p #{shared_path}/config"
        location = File.expand_path('../templates/kewatcher_init.sh.erb', __FILE__)
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
