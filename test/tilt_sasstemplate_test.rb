require_relative 'test_helper'
require 'tmpdir'

checked_describe 'tilt/sass' do
  it "is registered for '.sass' files" do
    assert_equal Tilt::SassTemplate, Tilt['test.sass']
  end

  it "sets allows_script metadata set to false" do
    assert_equal false, Tilt::SassTemplate.new{''}.metadata[:allows_script]
  end

  it "compiles and evaluates the sass template on #render" do
    template = Tilt::SassTemplate.new({ style: :compressed }) { |t| "#main\n  background-color: #0000f1" }
    3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
  end

  it "compiles and evaluates the sass template on #render with unsupported options" do
    template = Tilt::SassTemplate.new({ style: :compressed, outvar: '@a' }) { |t| "#main\n  background-color: #0000f1" }
    3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
  end

  it "is registered for '.scss' files" do
    assert_equal Tilt::ScssTemplate, Tilt['test.scss']
  end

  it "compiles and evaluates the scss template on #render" do
    template = Tilt::ScssTemplate.new({ style: :compressed }) { |t| "#main {\n  background-color: #0000f1;\n}" }
    3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
  end

  it "compiles and evaluates the scss template on #render with unsupported options" do
    template = Tilt::ScssTemplate.new({ style: :compressed, outvar: '@a' }) { |t| "#main {\n  background-color: #0000f1;\n}" }
    3.times { assert_equal "#main{background-color:#0000f1}", template.render.chomp }
  end

  it "escapes reserved characters in file URL paths" do
    Dir.mktmpdir('tilt-sass') do |dir|
      path = File.join(dir, 'question?mark.scss')
      File.write(path, "#main { color: red; }")

      assert_match '#main', Tilt::ScssTemplate.new(path).render
    end
  end
end
