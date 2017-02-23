require 'security'
require 'highline/import' # to hide the entered password

module Firim
  class AccountManager
    DEFAULT_PREFIX = "firim"
    DEFAULT_USERNAME = "default"
    # @param prefix [String] Very optional, is used for the 
    # prefix on keychain
    # @param note [String] An optional note that will be shown next
    #   to the token and token prompt
    def initialize(user: nil, token: nil, prefix: nil, note: nil)
      @prefix = prefix || DEFAULT_PREFIX

      @user = user
      @token = token
      @note = note
    end

    # Is the prefix default prefix "firim"
    def default_prefix?
      @prefix == DEFAULT_PREFIX
    end

    def fetch_token_from_env
      ENV["FIRIM_TOKEN"]
    end

    def token(ask_if_missing: true)
      @token ||= fetch_token_from_env

      unless @token
        item = Security::InternetPassword.find(server: server_name)
        @token ||= item.password if item
      end
      ask_for_token while ask_if_missing && @token.to_s.length == 0
      return @token
    end

    def add_to_keychain
      Security::InternetPassword.add(server_name, @user, token)
    end

    def remove_from_keychain
      Security::InternetPassword.delete(server: server_name)
      @token = nil
    end

    def server_name
      "#{@prefix}.#{user_or_defualt}"
    end

    def user_or_defualt
      if @user.to_s.length == 0
        return DEFAULT_USERNAME
      end
      @user
    end

    def ask_for_token
      puts "-------------------------------------------------------------------------------------".green
      puts "Please provide your Firim Token".green
      puts "The Token you enter will be stored in your macOS Keychain".green
      if default_prefix?
        # We don't want to show this message, if we ask for the application specific token
        # which has a different prefix
        puts "You can also pass the token using the `FIRIM_TOKEN` environment variable".green
      end
      puts "Or fill in Firimfile `firim_api_token`".green
      puts "-------------------------------------------------------------------------------------".green

      if @user.to_s.length == 0
        raise "running in non-interactive shell" if $stdout.isatty == false
        prompt_text = "Username(not necessary)"
        prompt_text += " (#{@note})" if @note
        prompt_text += ": "
        @user = ask(prompt_text)
      end

      while @token.to_s.length == 0
        raise "Missing Token for #{user_or_defualt}, and running in non-interactive shell" if $stdout.isatty == false
        note = @note + " " if @note
        @token = ask("Token (#{note}for #{user_or_defualt}): ") { |q| q.echo = "*" }
      end

      return true if (/darwin/ =~ RUBY_PLATFORM).nil? # mac?, since we don't have access to the helper here

      # Now we store this information in the keychain
      if add_to_keychain
        return true
      else
        puts "Could not store token in keychain".red
        return false
      end

    end
  end
end