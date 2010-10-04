require_relative 'visual_resource_helper'

require 'scene'
include RSiD

TexPlay.set_options(caching: false)

describe Scene do
  before :each do
    @id = 'fb7308b69631'
    @name = 'eve apple'
  end

  it_should_behave_like "VisualResource"
end