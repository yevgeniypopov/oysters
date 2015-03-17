require "oysters/version"
require "capistrano"

unless Capistrano::Configuration.respond_to?(:instance)
  abort "oysters require Capistrano 2 and a bottle of champagne"
end

module Oysters
  def self.with_configuration(&block)
    Capistrano::Configuration.instance(:must_exist).load do
      namespace :oysters, &block
    end
  end
end
