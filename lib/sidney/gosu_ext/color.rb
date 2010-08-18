module Gosu
  class Color
    def self.from_rgb(r, g, b)
      new(255, r, g, b)
    end

    def self.from_rgba(r, g, b, a)
      new(a, r, g, b)
    end
    
    def self.from_argb(a, r, g, b)
      new(a, r, g, b)
    end
  end
end