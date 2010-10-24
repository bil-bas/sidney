# encoding: utf-8

require 'json'

module Sidney
  # Based on on an example by St.Woland
  # http://stackoverflow.com/questions/2080347/activerecord-serialize-using-json-instead-of-yaml
  class JsonSerializationWrapper
    protected
    def initialize(*attributes)
      @attributes = attributes
    end

    public
    def serialize(record)
      @attributes.each do |attribute|
        record.send("#{attribute}=", record.send(attribute).to_json)
      end
      nil
    end

    public
    def unserialize(record)
      @attributes.each do |attribute|
        record.send("#{attribute}=", JSON.parse(record.send(attribute)))
      end
      nil
    end

    alias_method :before_save, :serialize
    alias_method :after_save, :unserialize
    alias_method :after_find, :unserialize
  end
end