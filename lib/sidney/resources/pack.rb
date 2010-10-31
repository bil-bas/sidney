# encoding: utf-8

require_relative 'visual_resource'

module Sidney
  class Pack < Resource
    has_and_belongs_to_many :scenes
    has_one :sprite

    def image
      @image ||= Image.create(32, 32, color: :red)
      @image.rect 10, 10, 22, 22
      @image
    end

    def thumbnail
      image
    end
  end
end