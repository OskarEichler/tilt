# frozen_string_literal: true

# = String
#
# The template source is evaluated as a Ruby string. The #{} interpolation
# syntax can be used to generated dynamic output.
#
# === Related module
#
# * Tilt::StringTemplate

require_relative 'template'

module Tilt
  class StringTemplate < Template
    def prepare
      hash = "TILT#{@data.hash.abs}"
      @freeze_string_literals = !!@options[:freeze]
      data = @data
      if data.end_with?("\r")
        data = data[0...-1]
        suffix = ' << "\r"'
      end
      @code = String.new("(<<#{hash})[0...-1]#{suffix}\n#{data}\n#{hash}")
    end

    def precompiled_template(locals)
      @code
    end

    def precompiled(locals)
      source, offset = super
      [source, offset + 1]
    end

    def freeze_string_literals?
      @freeze_string_literals
    end
  end
end
