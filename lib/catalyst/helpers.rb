# frozen_string_literal: true

require 'action_view'
require_relative './manifest'

module Catalyst
  module Helpers
    include ActionView::Helpers::TagHelper

    def catalyst_javascript_vendor_include_tag
      if Catalyst.development?
        catalyst_javascript_include_tag('vendor-dll')
      end
    end

    def catalyst_javascript_include_tag(path)
      path = path.to_s.gsub(/\.js\z/, '')

      content_tag(
        :script,
        nil,
        type: 'text/javascript',
        crossorigin: 'anonymous',
        src: ::Catalyst::Manifest["#{path}.js"]
      )
    end

    def catalyst_stylesheet_link_tag(path)
      path = path.to_s.gsub(/\.css\z/, '')

      unless Catalyst.development?
        content_tag(
          :link,
          nil,
          href: ::Catalyst::Manifest["#{path}.css"],
          media: 'screen',
          rel: 'stylesheet'
        )
      end
    end

    def catalyst_asset_path(path)
      ::Catalyst::Manifest[path]
    end

    def catalyst_asset_url(path)
      if Catalyst.development? || Catalyst.config.assets_host.nil?
        catalyst_asset_path(path)
      else
        "#{Catalyst.config.assets_host_protocol}://#{Catalyst.config.assets_host}#{catalyst_asset_path(path)}"
      end
    end
  end
end
