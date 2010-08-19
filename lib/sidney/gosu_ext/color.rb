module Gosu
  class Color
    # RGB in 0..255 format (Alpha assumed 255)
    def self.from_rgb(r, g, b)
      new(255, r, g, b)
    end

    # RGBA in 0..255 format
    def self.from_rgba(r, g, b, a)
      new(a, r, g, b)
    end

    # ARGB in 0..255 format (equivalent to new, but clearer)
    def self.from_argb(a, r, g, b)
      new(a, r, g, b)
    end

    # Convert from a 0.0..1.0 RGBA array, as used by Texplay.
    def self.from_texplay(color)
      from_rgba *color.map {|c| (c * 255).to_i }
    end

    # Convert to a 0.0..1.0 RGBA array, as used by Texplay.
    def self.to_texplay
      [red / 255.0, green / 255.0, blue / 255.0,  alpha / 255.0]
    end
  end
end