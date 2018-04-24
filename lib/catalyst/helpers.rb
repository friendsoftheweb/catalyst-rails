# frozen_string_literal: true

require 'action_view'
require_relative './manifest'

module Catalyst
  module Helpers
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    def catalyst_javascript_include_tag(path)
      path = path.to_s.sub(/\.js\z/, '') + '.js'

      if catalyst_referenced_files.include?(path)
        raise ::Catalyst::Manifest::DuplicateAssetReference,
              "The asset \"#{path}\" has already been referenced."
      end

      catalyst_referenced_files << path

      safe_join([
        catalyst_javascript_vendor_include_tag,
        catalyst_javascript_common_include_tag,
        content_tag(
          :script,
          nil,
          type: 'text/javascript',
          crossorigin: 'anonymous',
          src: ::Catalyst::Manifest[path]
        )
      ])
    end

    def catalyst_javascript_vendor_include_tag
      path = 'vendor-dll.js'

      return nil unless ::Catalyst.development?
      return nil if catalyst_referenced_files.include?(path)

      catalyst_javascript_include_tag(path)
    end

    def catalyst_javascript_common_include_tag
      path = 'common.js'

      return nil if catalyst_referenced_files.include?(path)

      if ::Catalyst.development? || ::Catalyst::Manifest.has?(path)
        catalyst_javascript_include_tag(path)
      end
    end

    def catalyst_stylesheet_link_tag(path)
      return nil if ::Catalyst.development?

      path = path.to_s.sub(/\.css\z/, '') + '.css'

      if catalyst_referenced_files.include?(path)
        raise ::Catalyst::Manifest::DuplicateAssetReference,
              "The asset \"#{path}\" has already been referenced."
      end

      catalyst_referenced_files << path

      safe_join([
        catalyst_common_stylesheet_link_tag,
        content_tag(
          :link,
          nil,
          href: ::Catalyst::Manifest[path],
          media: 'screen',
          rel: 'stylesheet'
        )
      ])
    end

    def catalyst_common_stylesheet_link_tag
      path = 'common.css'

      return nil if catalyst_referenced_files.include?(path)

      if ::Catalyst::Manifest.has?(path)
        catalyst_stylesheet_link_tag(path)
      end
    end

    def catalyst_asset_path(path)
      ::Catalyst::Manifest[path]
    end

    def catalyst_asset_url(path)
      if ::Catalyst.development? || ::Catalyst.config.assets_host.nil?
        catalyst_asset_path(path)
      else
        "#{Catalyst.config.assets_host_protocol}://#{Catalyst.config.assets_host}#{catalyst_asset_path(path)}"
      end
    end

    def catalyst_referenced_files
      @catalyst_referenced_files ||= Set.new
    end
  end
end
