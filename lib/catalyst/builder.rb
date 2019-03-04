# frozen_string_literal: true

require 'singleton'
require 'forwardable'
require_relative './config'

module Catalyst
  class Builder
    BUILD_COMMAND = 'yarn run catalyst build'

    include Singleton

    class << self
      extend Forwardable
      def_delegator :instance, :build!
    end

    def build!(environment = nil)
      Catalyst.check_for_catalyst!

      environment ||= Catalyst.config.environment

      case environment
      when :test
        test_build!
      when :production
        production_build!
      else
        raise ArgumentError,
              'Invalid environment. Must be one of: :test, :production.'
      end
    end

    private

    def test_build!
      unless Catalyst.config.running_feature_tests.call
        Catalyst.log('Not running feature tests -- skipping build')
        return
      end

      # Only rebuild the assets if they've been modified since the last time
      # they were built successfully.
      if assets_last_built >= assets_last_modified
        Catalyst.log('Assets have not been modified -- skipping build')
        return
      end

      if system("NODE_ENV=test #{BUILD_COMMAND}")
        unless assets_last_built_file_path.nil?
          begin
            FileUtils.touch(assets_last_built_file_path)
          rescue Errno::ENOENT
          end
        end
      else
        puts <<~MESSAGE
          \e[31m
          ***************************************************************
          *                                                             *
          *          Failed to compile assets with Catalyst!            *
          *  Make sure 'yarn run catalyst build' runs without failing.  *
          *                                                             *
          ***************************************************************\e[0m
        MESSAGE

        exit 1
      end
    end

    def production_build!
      unless system("NODE_ENV=production #{BUILD_COMMAND}")
        Catalyst.log('Failed to compile assets!')

        exit 1
      end
    end

    def assets_last_modified
      asset_paths.lazy.map { |path| File.ctime(path) }.max || Time.now
    end

    def asset_paths
      if ::Catalyst::Config.root_path
        Dir.glob(File.join(::Catalyst::Config.root_path, '**/*.{js,ts,tsx,scss}')) + [
          File.join(Dir.pwd, 'yarn.lock')
        ]
      else
        []
      end
    end

    def assets_last_built_file_path
      if defined?(Rails)
        Rails.root.join('tmp/assets-last-built')
      end
    end

    def assets_last_built
      if assets_last_built_file_path.nil?
        Time.at(0)
      else
        File.mtime(assets_last_built_file_path) rescue Time.at(0)
      end
    end
  end
end
