require_relative 'visual_resource_helper'

require 'sprite'
include Sidney

describe Sprite do
  before :each do
    @id = '009a8897cf6b'
    @name = 'grapefruit'
  end

  it_should_behave_like "VisualResource"

  describe "#default" do
    subject { described_class.default }

    it "should be black and transparent" do
      color = [0, 0, 0, 0]
      (0...16).each do |y|
        (0...16).each do |x|
          subject.image.get_pixel(x, y).should == color
        end
      end
    end
  end

  describe "#to_tile" do
    subject { described_class.load(@id) }

    before :each do
      @tile = subject.to_tile
    end

    it "should be a Tile" do
      @tile.should be_a_kind_of Tile
    end

    it "should have the same id, name and image" do
      @tile.id.should == subject.id
      @tile.name.should == subject.name
      @tile.image.should == subject.image
    end
  end
end