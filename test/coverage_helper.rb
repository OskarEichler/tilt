if ENV.delete('COVERAGE')
  require 'simplecov'

  SimpleCov.start do
    coverage :line
    coverage :branch
    cover "lib/**/*.rb"
    group('Missing'){|src| src.covered_percent < 100}
    skip{|src| src.filename =~ %r{lib/tilt/(_emacs_org|_handlebars|_jbuilder|_org|haml).rb\z}}
  end
end
