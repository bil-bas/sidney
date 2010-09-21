require_relative 'visual_resource_helper'

require 'scene'
include RSiD

describe Scene do
  before :each do
    @uid = 'fb7308b69631'
    @name = 'eve apple'
  end

  it_should_behave_like "VisualResource"

  describe "default()" do
    before :each do
      @resource = described_class.default
    end
  end

  describe "to_image()" do
    it "should render the second time the same as the first" do
      @resource.to_image.should == @resource.to_image
      true.should be_false
    end
  end
end