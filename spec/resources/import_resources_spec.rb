require_relative '../helper'

require 'import_resources'

describe "RSiD#import" do
  before :all do
    $window = Gosu::Window.new(640, 480, false)
  end

  it "should import a whole host of things" do
    RSiD.import_resources(CACHE_IN)
  end
end