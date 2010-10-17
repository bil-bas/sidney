require_relative '../helper'

require 'game'
require 'import_resources'

module Sidney
describe Resource do
  before :all do
    Game.new(false)
    Resource.import_sid_resource_cache(CACHE_IN)
  end

  describe "#import_sid" do
    it "should import the correct number of scenes" do
      Scene.count.should == 7
    end

    it "should import the correct number of rooms" do
      Room.count.should == 3
    end

    it "should import the correct number of tiles" do
      Tile.count.should == 21
    end

    it "should import the correct number of sprites" do
      Sprite.count.should == 93
    end

    it "should import the correct number of state objects" do
      StateObject.count.should == 47
    end
  end
end
end