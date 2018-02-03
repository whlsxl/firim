module Firim
  class DetectValues
    def run!(options)
      find_firim_api_token(options)
      find_app_identifier(options)
      find_app_name(options)
      find_version(options)
      find_build_version(options)
    end

    def find_app_identifier(options)
      identifier = FastlaneCore::IpaFileAnalyser.fetch_app_identifier(options[:ipa])
      if identifier.to_s.length != 0
        options[:app_identifier] = identifier
      else
        UI.user_error!("Could not find ipa with app identifier '#{options[:app_identifier]}' in your iTunes Connect account (#{options[:username]} - Team: #{Spaceship::Tunes.client.team_id})")
      end
    end

    def find_app_name(options)
      return if options[:app_name]
      plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(options[:ipa])
      options[:app_name] ||= plist['CFBundleDisplayName']
      options[:app_name] ||= plist['CFBundleName']
    end

    def find_version(options)
      options[:app_version] ||= FastlaneCore::IpaFileAnalyser.fetch_app_version(options[:ipa])
    end

    def find_build_version(options)
      plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(options[:ipa])
      options[:app_build_version] = plist['CFBundleVersion']
    end

    def find_firim_api_token(options)
      option_token = options[:firim_api_token]
      keychain_token = Firim::AccountManager.new(user: options[:firim_username])
      token = keychain_token.token(ask_if_missing: option_token == nil)
      if token
        options[:firim_api_token] = token
        return
      end

      options[:firim_api_token] ||= UI.input("The API Token of fir.im: ")
    end
  end

  class DetectAndroidValues
    def run!(options)
      find_firim_api_token(options)
      find_app_identifier(options)
      find_app_name(options)
      find_version(options)
      find_build_version(options)
    end

    def read_key_from_gradle_file(gradle_file, key)
      return nil if gradle_file == nil
      value = nil
      begin
        file = File.new(gradle_file, "r")
        while (line = file.gets)
          next unless line.include? key
          components = line.strip.split(' ')
          value = components[components.length - 1].tr("\"", "")
          break
        end
        file.close
      rescue => err
        UI.error("An exception occured while reading gradle file: #{err}")
        err
      end
      return value
    end

    def find_app_identifier(options)
      return if options[:app_identifier]
      options[:app_identifier] ||= self.read_key_from_gradle_file(options[:gradle_file], "applicationId")
    end

    def find_app_name(options)
      return if options[:app_name]
      options[:app_name] ||= self.read_key_from_gradle_file(options[:gradle_file], "appName")
    end

    def find_version(options)
      return if options[:app_version]
      options[:app_version] ||= self.read_key_from_gradle_file(options[:gradle_file], "versionName")
    end

    def find_build_version(options)
      return if options[:app_build_version]
      options[:app_build_version] ||= self.read_key_from_gradle_file(options[:gradle_file], "versionCode")
    end

    def find_firim_api_token(options)
      option_token = options[:firim_api_token]
      keychain_token = Firim::AccountManager.new(user: options[:firim_username])
      token = keychain_token.token(ask_if_missing: option_token == nil)
      if token
        options[:firim_api_token] = token
        return
      end

      options[:firim_api_token] ||= UI.input("The API Token of fir.im: ")
    end

  end

end
