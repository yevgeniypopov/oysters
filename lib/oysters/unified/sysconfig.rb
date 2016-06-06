require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :unified do
    namespace :sysconfig do
      #Run this task as clduser!
      desc 'Copy sysconfig to /etc/sysconfig'
      task :install, roles: :app do
        config_path = "/home/#{user}/#{application}_config"

        run "mkdir -p #{config_path}", :shell => :bash
        location = File.expand_path('../templates/app_sysconfig.sh.erb', __FILE__)
        config = ERB.new(File.read(location))
        put config.result(binding), "#{config_path}/deployed_application_sysconfig.sh", :shell => :bash

        sudo "cp #{config_path}/deployed_application_sysconfig.sh /etc/sysconfig/deployed_application", pty: true, :shell => :bash
      end

      #Run this task as clduser!
      desc 'Remove sysconfig'
      task :uninstall, roles: :app do
        sudo "sudo rm -f /etc/sysconfig/deployed_application", pty: true, :shell => :bash
      end
    end
  end
end
