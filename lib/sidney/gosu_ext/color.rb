require 'gosu'

module Gosu
  class Color
    # RGB in 0..255 format (Alpha assumed 255)
    def self.rgb(red, green, blue)
      new(255, red, green, blue)
    end

    # RGBA in 0..255 format
    def self.rgba(red, green, blue, alpha)
      new(alpha, red, green, blue)
    end

    # ARGB in 0..255 format (equivalent to Color.new, but explicit)
    def self.argb(alpha, red, green, blue)
      new(alpha, red, green, blue)
    end

    # Convert from a 0.0..1.0 RGBA array, as used by Texplay.
    def self.from_texplay(color)
      rgba(*color.map {|c| (c * 255).to_i })
    end

    # Convert to a 0.0..1.0 RGBA array, as used by Texplay.
    def self.to_texplay
      [red / 255.0, green / 255.0, blue / 255.0,  alpha / 255.0]
    end
  end
end