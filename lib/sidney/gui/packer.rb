# encoding: utf-8

require_relative 'container'

module Sidney
module Gui
  # Container that auto-packs elements.
  #
  # @abstract
  class Packer < Container
    DEFAULT_SPACING_X, DEFAULT_SPACING_Y = 5, 5

    attr_reader :spacing_x, :spacing_y

    protected
    def initialize(parent, options = {})
      options = {
        spacing_x: DEFAULT_SPACING_X,
        spacing_y: DEFAULT_SPACING_Y,
      }.merge! options

      @spacing_x = options[:spacing_x]
      @spacing_y = options[:spacing_y]

      super(parent, options)
    end
  end
end
end