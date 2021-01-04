# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
require 'singleton'
require 'forwardable'
require 'json'
require_relative './errors'

module Catalyst
  class Config
    extend T::Sig
    sig { returns(String) }
    def self.catalyst_config_path
      File.expand_path('./catalyst.config.json', Catalyst.config.pwd)
    end

    sig { returns(String) }
    def self.package_path
      File.expand_path('./package.json', Catalyst.config.pwd)
    end

    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :context_path
    end

    sig { void }
    def initialize
      @values =
        T.let(
          if File.exist?(self.class.catalyst_config_path)
            JSON.parse(File.read(self.class.catalyst_config_path))
          elsif File.exist?(self.class.package_path)
            JSON.parse(File.read(self.class.package_path))['catalyst']
          else
            raise ::Catalyst::MissingConfig,
                  "Missing 'catalyst.config.json' or 'package.json' file in: #{
                    Catalyst.config.pwd
                  }"
          end,
          T::Hash[String, T.untyped]
        )

      raise ::Catalyst::MissingConfig, <<~MESSAGE if @values.nil?
        Missing "catalyst" config in package.json file.
        Please follow the instructions here to set up Catalyst:
        https://github.com/friendsoftheweb/catalyst
      MESSAGE
    end

    sig { returns(String) }
    def context_path
      File.join(
        Catalyst.config.pwd,
        @values['contextPath'] || @values['rootPath']
      )
    end
  end
end
