# typed: strong
# frozen_string_literal: true

module Catalyst
  CatalystError = Class.new(StandardError)
  NotInstalled = Class.new(CatalystError)
  MissingConfig = Class.new(CatalystError)
end
