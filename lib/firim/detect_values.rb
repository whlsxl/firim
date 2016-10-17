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
      return if options[:firim_api_token]
      options[:firim_api_token] ||= UI.input("The API Token of fir.im: ")
    end
  end
end