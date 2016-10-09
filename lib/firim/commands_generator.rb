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

    def run
      program :version, Firim::VERSION
      program :description, Firim::DESCRIPTION
      program :help, 'Author', 'Hailong Wang <whlsxl+g@gmail.com>'
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane/tree/master/deliver'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(Firim::Options.available_options)
      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'firim'
        c.description = 'Upload binary to Fir.im'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Firim::Options.available_options, options.__hash__)
          loaded = options.load_configuration_file("Firimfile")
          loaded = true if options[:firim_api_token]
          unless loaded
            if UI.confirm("No firim configuration found in the current directory. Do you want to setup firim?")
              require 'deliver/setup'

              return 0
            end
          end
        end
      end

    end
  end
end