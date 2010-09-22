require_relative 'visual_resource_helper'

require 'sprite'
include RSiD

describe Sprite do
  before :all do
    $window = Gosu::Window.new(640, 480, false)
  end

  before :each do
    @uid = '009a8897cf6b'
    @name = 'grapefruit'
  end

  it_should_behave_like "VisualResource"

  describe "default()" do
    subject { described_class.default }

    it "should be black and transparent" do
      color = [0, 0, 0, 0]
      (0...16).each do |y|
        (0...16).each do |x|
          subject.to_image.get_pixel(x, y).should == color
        end
      end
    end
  end

  describe "to_tile()" do
    subject { described_class.load(@uid) }

    before :each do
      @tile = subject.to_tile
    end

    it "should be a Tile" do
      @tile.should be_a_kind_of Tile
    end

    it "should have the same uid, name and image" do
      @tile.uid.should == subject.uid
      @tile.name.should == subject.name
      @tile.image.should == subject.image
    end
  end
end