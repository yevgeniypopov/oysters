require 'oysters'

Oysters.with_configuration do
  namespace :initd do

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

  end
end
