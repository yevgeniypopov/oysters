require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :unified do
    # This tasks are used to start/stop/restart next application daemons:
    # - KEWatcher from resque-sliders gem
    # - Resque Scheduler
    # - Unicorn
    [:kewatcher, :resque_scheduler, :unicorn].each do |program|
      namespace "#{program}" do
        [:stop, :start, :restart].each do |action|
          desc "#{action.to_s.capitalize} #{program.to_s.capitalize}"
          task action do
            run "/etc/init.d/#{application}_#{program} #{action.to_s}", pty: true
          end
        end
      end
    end
  end
end
