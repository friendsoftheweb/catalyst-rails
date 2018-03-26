# frozen_string_literal: true

require 'singleton'
require 'forwardable'
require 'json'
require_relative './errors'

module Catalyst
  class Config
    PACKAGE_PATH = File.expand_path('./package.json', Dir.pwd)

    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :root_path, :build_path
    end

    def initialize
      unless File.exists?(PACKAGE_PATH)
        raise ::Catalyst::MissingConfig,
              "Missing package.json file in: #{Dir.pwd}"
      end

      @values = JSON.parse(File.read(PACKAGE_PATH))['catalyst']

      if @values.nil?
        raise ::Catalyst::MissingConfig, <<~MESSAGE
          Missing "catalyst" config in package.json file.
          Please follow the instructions here to set up Catalyst:
          https://github.com/friendsoftheweb/catalyst
        MESSAGE
      end
    end

    def root_path
      File.join(Dir.pwd, @values['rootPath'])
    end

    def build_path
      File.join(Dir.pwd, @values['buildPath'])
    end
  end
end
