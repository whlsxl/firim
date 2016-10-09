require 'fastlane_core'
require 'credentials_manager'

module Firim
  class Options
    def self.available_options
      [
        # firim info
        FastlaneCore::ConfigItem.new(key: :firim_api_token,
                                     short_option: "-a",
                                     description: "fir.im user api token"),

        # Content path
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     short_option: "-i",
                                     env_name: "DELIVER_IPA_PATH",
                                     description: "Path to your ipa file",
                                     default_value: Dir["*.ipa"].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find ipa file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                     end,
                                     conflicting_options: [:pkg],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_icon,
                                     description: "Metadata: The path to the app icon",
                                     optional: true,
                                     short_option: "-l",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find png file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a png file") unless value.end_with?(".png")
                                     end),
        # APP info
        FastlaneCore::ConfigItem.new(key: :app_name,
                                     description: "The app's name",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_release_type,
                                     description: "The app's release type (Adhoc, Inhouse)",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :app_changelog,
                                     description: "The app's changelog",
                                     optional: true,
                                     is_string: false)
      ]
    end
  end
end