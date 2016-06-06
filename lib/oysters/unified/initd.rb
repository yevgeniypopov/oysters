require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :unified do
    [:kewatcher, :resque_scheduler, :unicorn].each do |program|
      namespace "#{program}" do
        desc "Install #{program}"
        task :install, roles: :app do
          config_path = "/home/#{user}/#{application}_config"

          run "mkdir -p #{config_path}", :shell => :bash
          location = File.expand_path("../scripts/#{program}_initd_script.sh", __FILE__)
          config = ERB.new(File.read(location))
          put config.result(binding), "#{config_path}/#{program}_initd_script.sh", :shell => :bash

          sudo "cp #{config_path}/#{program}_initd_script.sh /etc/init.d/#{application}_#{program};\
              sudo chmod +x /etc/init.d/#{application}_#{program};\
              sudo chkconfig --add #{application}_#{program}", pty: true, :shell => :bash
        end

        desc "Remove #{program} init.d script"
        task :uninstall, roles: :app do
          sudo "chkconfig --del #{application}_#{program};\
              sudo rm -f /etc/init.d/#{application}_#{program}", pty: true, :shell => :bash
        end
      end
    end
  end
end
