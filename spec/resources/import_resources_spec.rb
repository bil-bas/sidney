require_relative '../helper'

require 'import_resources'

include RSiD

describe Resource do
  before :all do
    $window = Gosu::Window.new(640, 480, false)

    Resource.import_sid(CACHE_IN)
  end

  describe "#import_sid" do
    it "should import the correct number of scenes" do
      Scene.count.should == 2
    end

    it "should import the correct number of rooms" do
      Room.count.should == 2
    end

    it "should import the correct number of tiles" do
      # Import says there are 13 imported, but it comes out 14. Odd.
      Tile.count.should == 13
    end

    it "should import the correct number of sprites" do
      Sprite.count.should == 49
    end

    it "should import the correct number of state objects" do
      StateObject.count.should == 27
    end
  end
end