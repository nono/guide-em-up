#!/usr/bin/env ruby

require "minitest/autorun"
require "guide-em-up"


describe GuideEmUp do
  before do
    @dir = File.expand_path("../..", __FILE__)
    @guide = GuideEmUp::Guide.new("#{@dir}/README.md")
  end


  it "has a version number" do
    GuideEmUp::VERSION.must_match /\d+\.\d+\.\d+/
  end


  describe "Guide" do
    it "has a title" do
      @guide.title.must_equal "#{@dir}/README.md"
    end

    it "has an HTML content" do
      @guide.html.must_match "<html>"
      @guide.html.scan("</h2>").length.must_equal 4
    end
  end
end
