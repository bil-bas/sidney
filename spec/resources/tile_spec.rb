require_relative 'visual_resource_helper'

require 'tile'
include Sidney

describe Tile do
  before :each do
    @id = '617ae2c65c39'
    @name = 'JPpath'
  end

  it_should_behave_like "VisualResource"

  describe "#default" do
    subject { described_class.default }

    it "should be blank and opaque" do
      blank = [0, 0, 0, 1]
      (0...16).each do |y|
        (0...16).each do |x|
          subject.image.get_pixel(x, y).should == blank
        end
      end
    end
  end

  describe "#to_sprite" do
    subject { described_class.load(@id) }

    before :each do
      @sprite = subject.to_sprite
    end

    it "should be a Sprite" do
      @sprite.should be_a_kind_of Sprite
    end

    it "should have the same id, name and image data" do
      @sprite.id.should == subject.id
      @sprite.name.should == subject.name
      @sprite.image.should == subject.image
    end
  end
end