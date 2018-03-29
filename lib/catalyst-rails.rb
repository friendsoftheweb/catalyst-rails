# frozen_string_literal: true

require 'dry-configurable'
require 'open3'

module Catalyst
  extend Dry::Configurable

  default_environment = if ENV['NODE_ENV']
    ENV['NODE_ENV'].to_sym
  elsif defined? Rails
    Rails.env.to_sym
  end

  default_manifest_path = if defined? Rails
    File.expand_path('./public/assets/manifest.json', Dir.pwd)
  end

  setting :environment, default_environment
  setting :manifest_path, default_manifest_path
  setting :assets_base_path, '/assets'
  setting :assets_host, ENV.fetch('HOST') { nil }
  setting :assets_host_protocol, 'https'
  setting :dev_server_host, ENV.fetch('DEV_SERVER_HOST') { 'localhost' }
  setting :dev_server_port, ENV.fetch('DEV_SERVER_PORT') { 8080 }.to_i
  setting :running_feature_tests, -> {
    !defined?(RSpec) || RSpec.world.all_example_groups.any? do |group|
      group.metadata[:type] == :system
    end
  }

  def self.log(message, level = :info)
    message = message.split("\n").reduce('') do |reduction, line|
      reduction + "\e[35m[Catalyst]\e[0m #{line}\n"
    end

    puts message
  end

  def self.development?
    config.environment == :development
  end

  def self.test?
    config.environment == :test
  end

  def self.production?
    config.environment == :production
  end

  def self.build!(environment = nil)
    ::Catalyst::Builder.build!(environment)
  end

  def self.serve!
    unless $catalyst_server_pid.nil?
      log(
        "A Catalyst server is already running (#{$catalyst_server_pid}).",
        :warn
      )

      return
    end

    check_for_catalyst!

    stdin, stdout, stderr, wait_thr = Open3.popen3('yarn start')

    $catalyst_server_pid = wait_thr.pid

    Thread.new do
      begin
        while line = stdout.gets
          puts line
        end
      rescue IOError
      end
    end

    at_exit do
      stdin.close
      stdout.close
      stderr.close
    end
  end

  def self.check_for_yarn!
    unless system 'which yarn > /dev/null 2>&1'
      raise NotInstalled, <<~MESSAGE
        The yarn binary is not available in this directory.
        Please follow the instructions here to install it:
        https://yarnpkg.com/lang/en/docs/install
      MESSAGE
    end
  end

  def self.check_for_catalyst!
    check_for_yarn!

    unless system 'yarn run which catalyst > /dev/null 2>&1'
      raise NotInstalled, <<~MESSAGE
        The catalyst binary is not available in this directory.
        Please follow the instructions here to intall it:
        https://github.com/friendsoftheweb/catalyst
      MESSAGE
    end
  end
end

require_relative './catalyst/version'
require_relative './catalyst/errors'
require_relative './catalyst/builder'
require_relative './catalyst/helpers'
require_relative './catalyst/manifest'
require_relative './catalyst/railtie' if defined? Rails
