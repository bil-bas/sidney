require_relative 'visual_resource_helper'

require 'scene'
include Sidney

describe Scene do
  before :each do
    @id = 'c108bf228e63'
    @name = 'JPsa1hou2E'
  end

  it_should_behave_like "VisualResource"
end