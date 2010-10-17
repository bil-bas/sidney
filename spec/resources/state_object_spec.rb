require_relative 'visual_resource_helper'

require 'state_object'
include Sidney

describe StateObject do
  before :each do
    @id = '7f8e311c4832'
    @name = 'JPcherryTr'
  end

  it_should_behave_like "VisualResource"

  describe "initialize() default" do
    subject { described_class.default }

    it "should have no layers" do
      subject.num_layers.should == 0
    end
  end
end
