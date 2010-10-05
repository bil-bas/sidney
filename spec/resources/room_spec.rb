require_relative 'visual_resource_helper'

require 'room'
include RSiD

describe Room do
  before :each do
    @id = '9c70e8396eeb'
    @name = 'closet az'
  end

  subject { described_class.load(@id) }

  it_should_behave_like "VisualResource"

  it "should contain all 300 tiles" do
    layers = subject.tile_layers
    layers.count.should == 300
    layers.where(x: 0, y: 0).first.should_not be_nil
    layers.where(x: 19, y: 14).first.should_not be_nil
  end

  describe "tile()" do
    it "should return all 169 grid tiles inside the grid area" do
      (0...15).each do |y|
        (0...20).each do |x|
          tile = subject.tile(x, y)
          tile.should be_a_kind_of Tile
        end
      end
    end

    it "should return nil outside the grid" do
      subject.tile(-1, -1).should be_nil
      subject.tile(20, 15).should be_nil
    end
  end

  describe "layers_by_x_y()" do
    it "should return 300 layers containing tiles" do
      layers = subject.layers_by_x_y
      layers.size.should == 300
      layers.each do |layer|
        layer.tile.should be_a_kind_of Tile
      end
    end
  end

  describe "default()" do
    subject { described_class.default }

    it "should contain only default tiles" do
      (0...15).each do |y|
        (0...20).each do |x|
          tile = subject.tile(x, y)
          tile.should == Tile.default
        end
      end
    end

    it "should have all tiles being passable" do
      (0...15).each do |y|
        (0...20).each do |x|
          subject.blocked?(x, y).should be_false
        end
      end
    end
  end
end