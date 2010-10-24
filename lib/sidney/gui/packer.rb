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
      }.merge! options

      @spacing_x = options[:spacing_x] || options[:spacing] || DEFAULT_SPACING_X
      @spacing_y = options[:spacing_y] || options[:spacing] || DEFAULT_SPACING_Y

      super(parent, options)
    end
  end
end
end