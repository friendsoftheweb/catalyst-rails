# frozen_string_literal: true

# typed: strict

require 'sorbet-runtime'

module Catalyst
  module ContentType
    extend T::Sig

    sig { params(filename: String).returns(Symbol) }
    def self.for_filename(filename)
      case File.extname(filename)
      when /\.(js)\z/
        :script
      when /\.(css)\z/
        :style
      when /\.(png|jpe?g|gif|webp)\z/
        :image
      when /\.(woff2?|ttf|eot)\z/
        :font
      when /\.(mp4|webm)\z/
        :video
      else
        raise StandardError,
              "Could not automatically determine the content type for: #{
                filename
              }"
      end
    end
  end
end
