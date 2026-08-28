# frozen_string_literal: true

require_relative 'template'

module Tilt
  # Superclass used for pipeline templates.  Should not be used directly.
  class Pipeline < Template
    def prepare
      @pipeline = self.class::TEMPLATES.inject(proc{|*| data}) do |data, (klass, ext, options)|
        proc do |s,l,&sb|
          render_options = options
          if ext_opts = @options[ext]
            render_options = render_options.merge(ext_opts)
          end
          klass.new(file, line, render_options, &proc{|*| data.call(s, l, &sb)}).render(s, l, &sb)
        end
      end
    end

    def evaluate(scope, locals, &block)
      @pipeline.call(scope, locals, &block)
    end
  end
end
