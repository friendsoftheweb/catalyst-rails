# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'action_view'
require_relative './manifest'
require_relative './content_type'

module Catalyst
  module Helpers
    extend T::Sig
    include Kernel
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    sig { params(path: T.any(String, Symbol), common: T::Boolean).returns(String) }
    def catalyst_javascript_include_tag(path, common: true)
      path = path.to_s.sub(/\.js\z/, '') + '.js'

      if catalyst_referenced_files.include?(path)
        raise ::Catalyst::Manifest::DuplicateAssetReference,
              "The asset \"#{path}\" has already been referenced."
      end

      catalyst_referenced_files << path

      if !common
        return(
          content_tag(
            :script,
            nil,
            type: 'text/javascript',
            crossorigin: 'anonymous',
            src: catalyst_asset_url(path)
          )
        )
      end

      safe_join(
        [
          catalyst_javascript_vendor_include_tag,
          catalyst_javascript_common_include_tag,
          content_tag(
            :script,
            nil,
            type: 'text/javascript',
            crossorigin: 'anonymous',
            src: catalyst_asset_url(path)
          )
        ]
      )
    end

    sig { returns(T.nilable(String)) }
    def catalyst_javascript_vendor_include_tag
      path = 'vendor-dll.js'

      return nil unless ::Catalyst.development?
      return nil if catalyst_referenced_files.include?(path)

      catalyst_javascript_include_tag(path)
    end

    sig { returns(T.nilable(String)) }
    def catalyst_javascript_common_include_tag
      path = 'common.js'

      return nil if catalyst_referenced_files.include?(path)

      if ::Catalyst.development? || ::Catalyst::Manifest.has?(path)
        catalyst_javascript_include_tag(path)
      end
    end

    sig { params(path: T.any(String, Symbol)).returns(T.nilable(String)) }
    def catalyst_stylesheet_link_tag(path)
      return nil if ::Catalyst.development?

      path = path.to_s.sub(/\.css\z/, '') + '.css'

      if catalyst_referenced_files.include?(path)
        raise ::Catalyst::Manifest::DuplicateAssetReference,
              "The asset \"#{path}\" has already been referenced."
      end

      catalyst_referenced_files << path

      safe_join(
        [
          catalyst_common_stylesheet_link_tag,
          content_tag(
            :link,
            nil,
            href: catalyst_asset_url(path),
            media: 'screen',
            rel: 'stylesheet'
          )
        ]
      )
    end

    sig { returns(T.nilable(String)) }
    def catalyst_common_stylesheet_link_tag
      path = 'common.css'

      return nil if catalyst_referenced_files.include?(path)

      catalyst_stylesheet_link_tag(path) if ::Catalyst::Manifest.has?(path)
    end

    sig { params(entry_name: T.any(String, Symbol)).returns(T.untyped) }
    def catalyst_link_tags_for(entry_name)
      safe_join(
        [
          catalyst_preload_link_tags_for(entry_name),
          catalyst_prefetch_link_tags_for(entry_name)
        ].flatten
      )
    end

    sig { params(entry_name: T.any(String, Symbol)).returns(T.untyped) }
    def catalyst_preload_link_tags_for(entry_name)
      safe_join(
        ::Catalyst::Manifest
          .preload_urls_for(entry_name)
          .map do |url|
            content_tag(
              :link,
              nil,
              {
                href: catalyst_asset_url(url),
                rel: 'preload',
                as: ::Catalyst::ContentType.for_filename(url)
              }
            )
          end
      )
    end

    sig { params(entry_name: T.any(String, Symbol)).returns(T.untyped) }
    def catalyst_prefetch_link_tags_for(entry_name)
      safe_join(
        ::Catalyst::Manifest
          .prefetch_urls_for(entry_name)
          .map do |url|
            content_tag(
              :link,
              nil,
              {
                href: catalyst_asset_url(url),
                rel: 'prefetch',
                as: ::Catalyst::ContentType.for_filename(url)
              }
            )
          end
      )
    end

    sig {params(path: String).returns(T.untyped)}
    def catalyst_preload_link_tag(path)
      content_tag(
        :link,
        nil,
        {
          href: catalyst_asset_url(path),
          rel: 'preload',
          as: ::Catalyst::ContentType.for_filename(path)
        }
      )
    end

    sig {params(path: String).returns(T.untyped)}
    def catalyst_prefetch_link_tag(path)
      content_tag(
        :link,
        nil,
        {
          href: catalyst_asset_url(path),
          rel: 'prefetch',
          as: ::Catalyst::ContentType.for_filename(path)
        }
      )
    end

    sig { params(path: T.any(String, Symbol)).returns(T.nilable(String)) }
    def catalyst_asset_path(path)
      ::Catalyst::Manifest[path]
    end

    sig { params(path: T.any(String, Symbol)).returns(T.nilable(String)) }
    def catalyst_asset_url(path)
      if ::Catalyst.development? || ::Catalyst.config.assets_host.nil?
        catalyst_asset_path(path)
      else
        "#{Catalyst.config.assets_host_protocol}://#{
          Catalyst.config.assets_host
        }#{catalyst_asset_path(path)}"
      end
    end

    def catalyst_referenced_files
      @catalyst_referenced_files ||= Set.new
    end
  end
end
