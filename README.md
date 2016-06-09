# Oysters
Oysters is a set of capistrano tasks that allow users to manage application daemons like Resque Scheduler, KEWatcher(resque-sliders), Unicorn.

It allows to:

1. Install/Uninstall init.d scripts for daemons.

2. Start/Stop/Restart daemons  

Oysters is compatible with Capistrano 2.x.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oysters'
```

And then execute:
```
$ bundle
```
Or install it yourself as:
```
$ gem install oysters
```
## Unified Oysters Usage

Require 'oysters/unified_oysters' in your deploy.rb:
```
require 'oysters/unified_oysters'
```
### init.d scripts installation

Set all needed configuration variables in your capistrano environment configs. See 'lib/oysters/unified/templates/app_sysconfig.sh.erb' for a list of all variables.:

```
set :app_user, 'svc_iris'
set :dynamic_schedule, true
set :scheduler_background, true
set :scheduler_verbose, 1
set :kewatcher_max_workers, 20
set :kewacther_redis_config, "#{current_path}/config/redis.yml"
set :kewatcher_verbose, '-vv'
set :unicorn_config_path, "#{current_path}/config/unicorn/unicorn.rb"
```

Install application sysconfig, used by init.d scripts. File '/etc/sysconfig/deployed_application' will be created:
```
cap <environment> oysters:unified:initd:sysconfig:install
```

Install necessary init.d scripts:
```
cap <environment> oysters:unified:initd:kewatcher:install
cap <environment> oysters:unified:initd:resque_scheduler:install
cap <environment> oysters:unified:initd:unicorn:install
```
You can install sysconfig and all init.d scripts simultaneously via 'install_all' task:
```
cap <environment> oysters:unified:initd:install_all
```
### Managing daemons

You can manage daemons using next tasks:
```
cap <environment> oysters:unified:kewatcher:restart
cap <environment> oysters:unified:kewatcher:start
cap <environment> oysters:unified:kewatcher:stop

cap <environment> oysters:unified:resque_scheduler:restart
cap <environment> oysters:unified:resque_scheduler:start
cap <environment> oysters:unified:resque_scheduler:stop

cap <environment> oysters:unified:unicorn:restart
cap <environment> oysters:unified:unicorn:start
cap <environment> oysters:unified:unicorn:stop
```
### Removing scripts

Individual init.d script:
```
cap <environment> oysters:unified:initd:unicorn:uninstall
```
All scripts and sysconfig:
```
cap <environment> oysters:unified:initd:uninstall_all
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/oysters/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
