module Fastlane
  module Actions
    class FirimAction < Action
      def self.run(config)
        require 'firim'
        config.load_configuration_file('Firimfile')

        config[:ipa] = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] if Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]

        ::Firim::Runner.new(config).run
      end

      def self.description
        "Uses firim to upload ipa/apk to fir.im"
      end

      def self.authors
        ["whlsxl"]
      end

      def self.available_options
        require "firim"
        require "firim/options"
        FastlaneCore::CommanderGenerator.new.generate(::Firim::Options.available_options)
      end

      # support ios/android now
      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
