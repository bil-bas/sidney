require 'digest/sha1'
require 'fileutils'

require_relative '../database'

require_relative 'resource_manager'

module RSiD
  # A resource has both a name and a unique identifier based on its data.
  class Resource < ActiveRecord::Base
    @abstract_class = true
    
    NAME_LENGTH = 10
    DEFAULT_NAME = "default"
    @@defaults = {}

    MAGIC_CODE = "SiD1977" # Used as a header for versioned resources.

    DEFAULT_VERSION = 1

    UID_PACK = "H12"
    UID_NUM_BYTES = 6
    UID_NUM_NIBBLES = UID_NUM_BYTES * 2

    NAME_PACK = 'Z*'

    validates_format_of :id, with: /\A[a-z0-9]{12}\Z/
    validates_length_of :name, in: 1..NAME_LENGTH

    def self.type
      type = self.to_s[/[^:]+$/].downcase
      type == 'stateobject' ? 'object' : type
    end

    # For unversioned files, assume a default version. Override this for
    # files that have specific versions.
    def self.current_version
      DEFAULT_VERSION
    end

    # Loads resource from wherever it can find it:
    # 1. Cached default resource if that is what is requested.
    # 2. Found in database.
    # 3. Gives the default object if object not otherwise found.
    #
    # == Parameters
    # :id:  [String]
    def self.load(id)
      if id == default.id
        default
      else
        where(id: id).first || default
      end
    end

    def self.import_sid_data(id, file_name)
      resource = if File.exist? file_name
        File.open(file_name, "rb") do |file|
          generate(data: file.read, id: id)
        end
      else
        default # Failed to load...meh!
      end

      resource.image # Force rendering and caching of the image if it hasn't already been done.

      resource
    end
    # Reads the version header within a data object, assuming
    # that it is there.
    #
    # == Parameters
    # :data: Binary data object [String]
    # Returns: [version number, number of bytes of data read]
    def self.read_version(data)
      if data =~ /^#{MAGIC_CODE}/
        # Version number immediately after the magic code.
        version = data[MAGIC_CODE.length].unpack("C")[0]
        if version > current_version
          raise Exception.new(version)
        end

        offset = MAGIC_CODE.length + 1
      else
        version = DEFAULT_VERSION
        offset = 0
      end

      [version, offset]
    end

    # Extract attribute hash from raw binary data.
    def self.attributes_from_data(data, attributes = {})
      attributes[:name] = data.unpack(NAME_PACK)[0]

      attributes
    end

    # Add a set of default attributes to a hash, only adding them
    # if they haven't already been defined.
    def self.default_attributes(attributes = {})
      attributes[:name] = DEFAULT_NAME unless attributes[:name]

      attributes
    end

    # - binary data, where id is unknown (:data)
    # - binary data along with a id, such as when read from a disk (:data, :id)
    # - attributes (:att1..:attN)
    def self.generate(options = {})
      if options[:data]
        options = attributes_from_data(options[:data], { id: options[:id] })
      elsif options.empty?
        options = default_attributes(options)
      end

      # Take out the image attribute, since it isn't stored in the database.
      image = options[:image]
      options.delete :image

      created = new(options)
      created.id = options[:id] if options[:id] # Fudge because it doesn't like :id being mass assigned?
      created.recalculate_id unless created.id

      created.save! if where(id: created.id).count == 0
      created.cache_image(image) if image
      created
    end

    def self.default
      @@defaults[type] ||= generate
    end

    def self.clear_defaults
      @@defaults = {}
    end

    def type
      self.class.type
    end

    def recalculate_id
      self.id = calculate_id
    end

    def calculate_id
      Digest::SHA1.hexdigest(to_binary)[0...UID_NUM_NIBBLES]
    end

    def ==(other)
      other.class == self.class and other.id == id
    end

    def to_binary
      [name].pack(NAME_PACK)
    end
  end
end