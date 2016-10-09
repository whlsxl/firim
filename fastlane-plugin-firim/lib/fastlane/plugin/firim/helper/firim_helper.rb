module Fastlane
  module Helper
    class FirimHelper
      # class methods that you define here become available in your action
      # as `Helper::FirimHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the firim plugin helper!")
      end
    end
  end
end
