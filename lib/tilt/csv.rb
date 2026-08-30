# frozen_string_literal: true

# = CSV
#
# CSV Template implementation.
#
# === Example
#
#    # Example of csv template
#    tpl = <<-EOS
#      # header
#      csv << ['NAME', 'ID']
#
#      # data rows
#      @people.each do |person|
#        csv << [person[:name], person[:id]]
#      end
#    EOS
#
#    @people = [
#      {:name => "Joshua Peek", :id => 1},
#      {:name => "Ryan Tomayko", :id => 2},
#      {:name => "Simone Carletti", :id => 3}
#    ]
#
#    template = Tilt::CSVTemplate.new { tpl }
#    template.render(self)
#
# === See also
#
# * http://ruby-doc.org/stdlib/libdoc/csv/rdoc/CSV.html
#
# === Related module
#
# * Tilt::CSVTemplate

require_relative 'template'
require 'csv'

module Tilt

  class CSVTemplate < Template
    self.default_mime_type = 'text/csv'

    def prepare
      @outvar = @options.delete(:outvar) || '_csvout'
      @literal_options = literal_options?(@options)
      unless @literal_options
        @csv_local = "__tilt_csv_#{object_id.abs}"
        if @fixed_locals
          @csv_fixed_locals = true
          fixed_locals = @fixed_locals[1...-1]
          fixed_locals = ", #{fixed_locals}" unless fixed_locals.empty?
          @fixed_locals = "(#{@csv_local}#{fixed_locals})"
        end
      end
    end

    def precompiled_template(locals)
      if @literal_options
        <<-RUBY
        #{@outvar} = CSV.generate(**#{@options}) do |csv|
          #{@data}
        end
      RUBY
      else
        <<-RUBY
        csv = #{@csv_local}
        #{@data}
        #{@outvar} = #{@csv_local}.string
      RUBY
      end
    end

    def precompiled(locals)
      source, offset = super
      [source, offset + 1]
    end

    def compiled_method(local_keys, scope_class=nil)
      unless @literal_options || @csv_fixed_locals
        local_keys = local_keys.dup
        local_keys << @csv_local.to_sym
      end
      super(local_keys, scope_class)
    end

    private

    def compile_template_method(local_keys, scope_class=nil)
      method = super
      return method if @literal_options

      options = @options.dup.freeze
      csv_local = @csv_local.to_sym
      wrapper = Module.new
      if @csv_fixed_locals
        wrapper.define_method(:render) do |*args, **locals, &block|
          CSV.generate(**options) do |csv|
            bound_method = method.bind(self)
            if locals.empty?
              bound_method.call(csv, *args, &block)
            else
              bound_method.call(csv, *args, **locals, &block)
            end
          end
        end
      else
        wrapper.define_method(:render) do |locals, &block|
          CSV.generate(**options) do |csv|
            method.bind(self).call(locals.merge(csv_local => csv), &block)
          end
        end
      end
      wrapper.instance_method(:render)
    end

    def literal_options?(value)
      case value
      when nil, true, false, Symbol, String, Integer, Float
        true
      when Array
        value.all?{|entry| literal_options?(entry)}
      when Hash
        !value.default_proc && value.all?{|key, entry| literal_options?(key) && literal_options?(entry)}
      else
        false
      end
    end

  end
end
