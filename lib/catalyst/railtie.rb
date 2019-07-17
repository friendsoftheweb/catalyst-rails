# typed: ignore
# frozen_string_literal: true

require_relative './helpers'

module Catalyst
  class Railtie < Rails::Railtie
    initializer 'catalyst_rails.view_helpers' do
      ActionView::Base.include(::Catalyst::Helpers)
    end

    rake_tasks do
      load File.expand_path('./tasks/build.rake', __dir__)
    end
  end
end
