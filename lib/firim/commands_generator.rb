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
      program :help, 'GitHub', 'https://github.com/whlsxl/firim'
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

      command :addtoken do |c|
        c.syntax = 'firim addtoken'
        c.description = 'Add a firim api token to keychain. username is not necessary, Just a sign for multiple api token.'

        c.option '--username username', String, 'Username to add(not necessary).'
        c.option '--token token', String, 'API token to add'

        c.action do |args, options|
          username = options.username || ask('Username(not necessary): ')
          token = options.token || ask('Password: ') { |q| q.echo = '*'}

          add(username, token)

          puts "Token #{username || '`default`'}: #{'*' * token.length} added to keychain."
        end
      end

      # Command to remove credential from Keychain
      command :removetoken do |c|
        c.syntax = 'firim removetoken'
        c.description = 'Removes a firim token from the keychain.'

        c.option '--username username', String, 'Username to remove(or default).'

        c.action do |args, options|
          username = options.username || ask('Username: ')

          remove(username)
        end
      end

      default_command :run

      run!
    end


    private

    # Add entry to Apple Keychain
    def add(username, token)
      Firim::AccountManager.new(
        user: username,
        token: token
      ).add_to_keychain
    end
    
    # Remove entry from Apple Keychain using AccountManager
    def remove(username)
      Firim::AccountManager.new(
        user: username
      ).remove_from_keychain
    end
  end
end