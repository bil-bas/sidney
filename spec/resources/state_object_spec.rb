require_relative 'visual_resource_helper'

require 'state_object'
include Sidney

describe StateObject do
  before :each do
    @id = '0037985b6c43'
    @name = 'know tree'
  end

  it_should_behave_like "VisualResource"

  describe "initialize() default" do
    subject { described_class.load(@id) }

    before :each do
      subject = described_class.default
    end

    it "should have no layers" do
      subject.num_layers.should == 0
    end
  end
end
