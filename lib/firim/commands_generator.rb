require 'commander'

module Firim
  class CommandsGenerator
    include Commander::Methods

    # def self.start
    #   FastlaneCore::UpdateChecker.start_looking_for_update('deliver')
    #   self.new.run
    # ensure
    #   FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
    # end

    def self.start
      self.new.run
    end

    def run
      program :version, Firim::VERSION
      program :description, 'fir.im command tool'
      program :help, 'Author', 'Hailong Wang <whlsxl+g@gmail.com>'
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane/tree/master/deliver'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(Firim::Options.available_options)
      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'firim'
        c.description = 'Upload binary and infomations to Fir.im'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Firim::Options.available_options, options.__hash__)
          loaded = options.load_configuration_file("Firimfile")
          loaded = true if options[:firim_api_token]
          unless loaded
            if UI.confirm("No firim configuration found in the current directory. Do you want to setup firim?")
              require 'deliver/setup'
              Firim::Setup.new.run(options)
              return 0
            end
          end
          Firim::Runner.new(options).run
        end
      end

      command :init do |c|
        c.syntax = 'firim init'
        c.description = 'Create the initial `Firimfile` configuration'
        c.action do |args, options|
          if File.exist?("Firimfile") or File.exist?("fastlane/Firimfile")
            UI.important("You already got a running firim setup in this directory")
            return 0
          end

          require 'firim/setup'
          options = FastlaneCore::Configuration.create(Firim::Options.available_options, options.__hash__)
          Firim::Setup.new.run(options)
        end
      end

      default_command :run

      run!
    end
  end
end