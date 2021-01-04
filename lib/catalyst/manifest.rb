# typed: strict
# frozen_string_literal: true

require 'singleton'
require 'forwardable'

require_relative './errors'

module Catalyst
  class Manifest
    AssetMissing = Class.new(::Catalyst::CatalystError)
    DuplicateAssetReference = Class.new(::Catalyst::CatalystError)

    extend T::Sig
    include Singleton

    class << self
      extend Forwardable

      def_delegators :instance,
                     :[],
                     :has?,
                     :preload_urls_for,
                     :prefetch_urls_for
    end

    sig { void }
    def initialize
      if Catalyst.development?
        @manifest = T.let({}, T::Hash[String, T.untyped])
      else
        if Catalyst.config.manifest_path.nil?
          raise 'Missing "manifest_path" configuration.'
        end

        @manifest =
          T.let(
            JSON.parse(File.read(Catalyst.config.manifest_path)),
            T::Hash[String, T.untyped]
          )
      end
    end

    sig { params(path: T.any(String, Symbol)).returns(T::Boolean) }
    def has?(path)
      path = path.to_s.gsub(%r{\A/+}, '')

      Catalyst.development? ? false : assets.key?(path)
    end

    sig { params(path: T.any(String, Symbol)).returns(String) }
    def [](path)
      path = path.to_s.gsub(%r{\A/+}, '')

      if Catalyst.development?
        dev_server_protocol = Catalyst.config.dev_server_protocol
        dev_server_host = Catalyst.config.dev_server_host
        dev_server_port = Catalyst.config.dev_server_port

        if dev_server_protocol.nil?
          raise ::Catalyst::CatalystError,
                'Missing "dev_server_protocol" configuration.'
        end

        if dev_server_host.nil?
          raise ::Catalyst::CatalystError,
                'Missing "dev_server_host" configuration.'
        end

        if dev_server_port.nil?
          raise ::Catalyst::CatalystError,
                'Missing "dev_server_port" configuration.'
        end

        "#{dev_server_protocol}://#{dev_server_host}:#{dev_server_port}/#{path}"
      elsif assets.key?(path)
        T.must(assets[path])
      else
        raise AssetMissing, "Couldn't find an asset for path: #{path}"
      end
    end

    sig { params(entry_name: T.any(String, Symbol)).returns(T::Array[String]) }
    def preload_urls_for(entry_name)
      return [] if Catalyst.development?

      entry_name = entry_name.to_s

      return [] unless preload.key?(entry_name)

      T.must(preload[entry_name])
    end

    sig { params(entry_name: T.any(String, Symbol)).returns(T::Array[String]) }
    def prefetch_urls_for(entry_name)
      return [] if Catalyst.development?

      entry_name = entry_name.to_s

      return [] unless prefetch.key?(entry_name)

      T.must(prefetch[entry_name])
    end

    private

    sig { returns(T::Hash[String, String]) }
    def assets
      @manifest['assets'] || {}
    end

    sig { returns(T::Hash[String, T::Array[String]]) }
    def preload
      @manifest['preload'] || {}
    end

    sig { returns(T::Hash[String, T::Array[String]]) }
    def prefetch
      @manifest['prefetch'] || {}
    end
  end
end
