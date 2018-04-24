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
      path = path.to_s.gsub(/\A\/+/, '')

      if Catalyst.development?
        false
      else
        @manifest.key?(path)
      end
    end

    def [](path)
      path = path.to_s.gsub(/\A\/+/, '')

      if Catalyst.development?
        dev_server_host = Catalyst.config.dev_server_host
        dev_server_port = Catalyst.config.dev_server_port

        if dev_server_host.nil?
          raise 'Missing "dev_server_host" configuration.'
        end

        if dev_server_port.nil?
          raise 'Missing "dev_server_port" configuration.'
        end

        return "http://#{dev_server_host}:#{dev_server_port}/#{path}"
      else
        if @manifest.key?(path)
          assets_base_path = Catalyst.config.assets_base_path

          if assets_base_path.nil?
            raise 'Missing "assets_base_path" configuration.'
          end

          return "#{assets_base_path}/#{@manifest[path]}"
        else
          raise AssetMissing, "Couldn't find an asset for path: #{path}"
        end
      end
    end
  end
end
