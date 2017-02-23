require 'firim/commands_generator'
require 'firim/detect_values'
require 'firim/options'
require 'firim/runner'
require 'firim/setup'
require "firim/version"
require "firim/account_manager"

require 'fastlane_core'

module Firim
  class << self
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI

  # Constant that captures the root Pathname for the project. Should be used for building paths to assets or other
  # resources that code needs to locate locally
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end
