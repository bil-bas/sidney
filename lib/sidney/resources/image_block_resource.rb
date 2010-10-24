# encoding: utf-8

require 'devil'
require 'devil/gosu'

require_relative 'visual_resource'

module Sidney
  class ImageBlockResource < VisualResource
    @abstract_class = true

    WIDTH = HEIGHT = 16 # 16x16 pixels per tile/sprite.
    AREA = WIDTH * HEIGHT
    COLOR_DATA_SIZE = AREA * 4

    def to_binary
      (id ? image : @@tmp_image).to_blob + super
    end

    def self.default_attributes(attributes = {})
      attributes[:image] = Image.create(WIDTH, HEIGHT, color: default_color, caching: false)
      @@tmp_image = attributes[:image]

      super(attributes)
    end

    def self.default_color
      const_get :DEFAULT_COLOR
    end
  end
end