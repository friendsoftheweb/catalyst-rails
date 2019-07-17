# typed: true
# frozen_string_literal: true

require 'singleton'
require 'forwardable'
require 'json'
require_relative './errors'

module Catalyst
  class Config
    CATALYST_CONFIG_PATH = File.expand_path('./catalyst.config.json', Dir.pwd)
    PACKAGE_PATH = File.expand_path('./package.json', Dir.pwd)

    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :context_path
    end

    def initialize
      @values = if File.exists?(CATALYST_CONFIG_PATH)
        JSON.parse(File.read(CATALYST_CONFIG_PATH))
      elsif File.exists?(PACKAGE_PATH)
        JSON.parse(File.read(PACKAGE_PATH))['catalyst']
      else
        raise ::Catalyst::MissingConfig,
              "Missing 'catalyst.config.json' or 'package.json' file in: #{Dir.pwd}"
      end

      if @values.nil?
        raise ::Catalyst::MissingConfig, <<~MESSAGE
          Missing "catalyst" config in package.json file.
          Please follow the instructions here to set up Catalyst:
          https://github.com/friendsoftheweb/catalyst
        MESSAGE
      end
    end

    def context_path
      File.join(Dir.pwd, @values['contextPath'] || @values['rootPath'])
    end
  end
end
