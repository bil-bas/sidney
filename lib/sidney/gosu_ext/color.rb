# encoding: utf-8

require 'json'
require 'gosu'

module Gosu
  class Color
    # Json serialization.
    public
    def to_json
      {
        'json_class' => self.class.name,
        'rgba' => [red, green, blue, alpha]
      }.to_json
    end

    public
    def self.json_create(attributes)
      rgba(*attributes['rgba'])
    end
  end
end


