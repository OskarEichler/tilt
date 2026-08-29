require_relative 'test_helper'
require_relative '../lib/tilt/plain'

describe "Tilt::PlainTemplate" do
  it "returns data given" do
    template = Tilt::PlainTemplate.new { 'foo' }
    2.times do
      assert_equal 'foo', template.render
    end
  end
end
