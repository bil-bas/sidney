require_relative 'helper'

require 'event'

module Sidney
describe Event do
  before :each do
    class EventTest
      include Event

      event :pie

      event :frog, :cheese
    end

    @object = EventTest.new
  end

  it "should have event publishers and handlers added" do
    [:pie, :frog, :cheese].each do |event|
      @object.should respond_to "on_#{event}"
      @object.should respond_to "publish_#{event}"
    end
  end

  describe "publish_*()" do
    it "should do nothing if there are no handlers" do
      @object.publish_frog # Just don't raise an error really
    end

    it "should pass the object as the first parameter" do
      @object.on_frog { |object| object.should == @object }
      @object.publish_frog
    end

    it "should call all the appropriate handlers, once each" do
      called = 0
      @object.on_frog { called += 1 }
      @object.on_frog { called += 8 }
      called.should == 0
      @object.publish_frog

      called.should == 9
    end

    it "should pass parameters passed to it" do
      called = 0
      @object.on_frog do |object, x, y|
        object.should == @object
        called += x + y
      end
      @object.publish_frog(1, 2)

      called.should == 3
    end
  end
end
end