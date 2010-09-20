require_relative 'visual_resource_helper'

require_relative 'state_object'
include RSiD

describe StateObject do
  before :each do
    @uid = '0037985b6c43'
    @name = 'know tree'
  end

  it_should_behave_like "VisualResource"

  describe "initialize() default" do
    before :each do
      @resource = described_class.default
    end

    it "should have no layers" do
      @resource.num_layers.should == 0
    end
  end
end
