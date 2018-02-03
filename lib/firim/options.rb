require 'fastlane_core'
require 'credentials_manager'

module Firim
  class Options
    def self.available_options
      [
         # firim platform
        FastlaneCore::ConfigItem.new(key: :platform,
                                     optional: true,
                                     description: "The fir platform, support ios/android"),
        # firim info
        FastlaneCore::ConfigItem.new(key: :firim_api_token,
                                     short_option: "-a",
                                     optional: true,
                                     description: "fir.im user api token"),
        FastlaneCore::ConfigItem.new(key: :firim_username,
                                     optional: true,
                                     description: "fir.im username, a sign for identify different token"),
        # Content path
        FastlaneCore::ConfigItem.new(key: :ipa,
                                     optional: true,
                                     short_option: "-i",
                                     env_name: "DELIVER_IPA_PATH",
                                     description: "Path to your ipa file",
                                     default_value: Dir["*.ipa"].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find ipa file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be an ipa file") unless value.end_with?(".ipa")
                                     end),
        FastlaneCore::ConfigItem.new(key: :apk,
                                     optional: true,
                                     env_name: "DELIVER_APK_PATH",
                                     description: "Path to your apk file",
                                     default_value: Dir["app/build/outputs/apk/prod/release/*.apk"].first,
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find apk file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be an apk file") unless value.end_with?(".apk")
                                     end,
                                     conflicting_options: [:ipa],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run.")
                                     end),
        FastlaneCore::ConfigItem.new(key: :gradle_file,
                                     short_option: "-g",
                                     optional: true,
                                     description: "Path to your gradle file"),
        FastlaneCore::ConfigItem.new(key: :icon,
                                     description: "Path to the app icon, MUST BE jpg",
                                     optional: true,
                                     short_option: "-l",
                                     verify_block: proc do |value|
                                       UI.user_error!("Could not find png file at path '#{value}'") unless File.exist?(value)
                                       UI.user_error!("'#{value}' doesn't seem to be a png file") unless value.end_with?(".jpg")
                                     end),

        FastlaneCore::ConfigItem.new(key: :file,
                                     optional: true,
                                     description: "Path to your pkg file"),
        # APP info
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     description: "The app's identifier",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_name,
                                     description: "The app's name",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_desc,
                                     description: "The app's desc",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_short,
                                     description: "The app's short URL",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_is_opened,
                                     description: "APP's download link whether opened",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_is_show_plaza,
                                     description: "Whether the app show in plaza",
                                     is_string: false,
                                     conflicting_options: [:app_is_opened],
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_passwd,
                                     description: "The app's download page password",
                                     conflicting_options: [:app_is_opened, :app_is_show_plaza],
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_store_link_visible,
                                     description: "Whether show store link in download page",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_version,
                                     description: "The app's version",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_build_version,
                                     description: "The app's build version",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_release_type,
                                     description: "The app's release type (Adhoc, Inhouse)",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :app_changelog,
                                     description: "The app's changelog",
                                     optional: true),
        # To file
        FastlaneCore::ConfigItem.new(key: :app_info_to_file_path,
                                     description: "Append all [app's name] : [URL] to this file",
                                     optional: true)
      ]
    end
  end
end
