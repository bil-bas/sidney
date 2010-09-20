require_relative 'visual_resource_helper'

require_relative 'room'
include RSiD

describe Room do
  before :each do
    @uid = '9c70e8396eeb'
    @name = 'closet az'
  end

  it_should_behave_like "VisualResource"

  it "should contain all 169 tiles" do
    layers = TileLayer.where(room_uid: @uid)
    layers.count.should == 169
    layers.where(x: 0, y: 0).first.should_not be_nil
    layers.where(x: 12, y: 12).first.should_not be_nil
  end

  describe "tile()" do
    it "should return all 169 grid tiles inside the grid area" do
      (0...13).each do |y|
        (0...13).each do |x|
          tile = @resource.tile(x, y)
          tile.should be_a_kind_of Tile
        end
      end
    end

    it "should return nil outside the grid" do
      @resource.tile(-1, -1).should be_nil
      @resource.tile(13, 13).should be_nil
    end
  end

  describe "layers_by_x_y()" do
    it "should return 169 layers containing tiles" do
      layers = @resource.layers_by_x_y
      layers.size.should == 169
      layers.each do |layer|
        layer.tile.should be_a_kind_of Tile
      end
    end
  end

  describe "default()" do
    before :each do
      @default_resource2 = described_class.default
    end

    it "should contain only default tiles" do
      (0...13).each do |y|
        (0...13).each do |x|
          tile = @default_resource2.tile(x, y)
          tile.should == Tile.default
        end
      end
    end

    it "should have all tiles being passable" do
      (0...13).each do |y|
        (0...13).each do |x|
          @default_resource2.blocked?(x, y).should be_false
        end
      end
    end
  end
end