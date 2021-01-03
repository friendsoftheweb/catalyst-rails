# typed: true
# frozen_string_literal: true

require 'singleton'
require 'forwardable'

require_relative './errors'

module Catalyst
  class Manifest
    AssetMissing = Class.new(::Catalyst::CatalystError)
    DuplicateAssetReference = Class.new(::Catalyst::CatalystError)

    include Singleton

    class << self
      extend Forwardable
      def_delegators :instance, :[], :has?
    end

    def initialize
      if Catalyst.development?
        @manifest = {}
      else
        if Catalyst.config.manifest_path.nil?
          raise 'Missing "manifest_path" configuration.'
        end

        @manifest = JSON.parse(File.read(Catalyst.config.manifest_path))
      end
    end

    def has?(path)
      path = path.to_s.gsub(%r{\A\/+}, '')

      Catalyst.development? ? false : @manifest.key?(path)
    end

    def [](path)
      path = path.to_s.gsub(%r{\A\/+}, '')

      if Catalyst.development?
        dev_server_host = Catalyst.config.dev_server_host
        dev_server_port = Catalyst.config.dev_server_port

        raise 'Missing "dev_server_host" configuration.' if dev_server_host.nil?

        raise 'Missing "dev_server_port" configuration.' if dev_server_port.nil?

        return "http://#{dev_server_host}:#{dev_server_port}/#{path}"
      else
        if @manifest.key?(path)
          return @manifest[path]
        else
          raise AssetMissing, "Couldn't find an asset for path: #{path}"
        end
      end
    end
  end
end
