begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant QI plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.8.0"
  raise "The Vagrant QI plugin is only compatible with Vagrant 1.8+"
end

module VagrantPlugins
  module Cienv
    class Plugin < Vagrant.plugin("2")
      name "Cienv"
      description "This plugin enabled Vagrant to work with QI QI environments"

      action_hook(:build_config, :environment_load) do |hook|
        hook.prepend(VagrantPlugins::Cienv::Action::BuildVagrantfile)
      end
      command("test") do
         require File.expand_path("../command/test", __FILE__)
         Command::Test
      end

      # This sets up our log level to be whatever VAGRANT_LOG is.
      def self.setup_logging
        require "log4r"

        level = nil
        begin
          level = Log4r.const_get(ENV["VAGRANT_LOG"].upcase)
        rescue NameError
          # This means that the logging constant wasn't found,
          # which is fine. We just keep `level` as `nil`. But
          # we tell the user.
          level = nil
        end

        # Some constants, such as "true" resolve to booleans, so the
        # above error checking doesn't catch it. This will check to make
        # sure that the log level is an integer, as Log4r requires.
        level = nil if !level.is_a?(Integer)

        # Set the logging level on all "vagrant" namespaced
        # logs as long as we have a valid level.
        if level
          logger = Log4r::Logger.new("vagrant_cienv")
          logger.outputters = Log4r::Outputter.stderr
          logger.level = level
          logger = nil
        end
      end
    end
  end
end

require 'vagrant-qienv/plugin'
