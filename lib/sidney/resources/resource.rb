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
    CACHE_DIR = "resourceCache"

    MAGIC_CODE = "SiD1977" # Used as a header for versioned resources.

    DEFAULT_VERSION = 1

    UID_PACK = "H12"
    UID_NUM_BYTES = 6
    UID_NUM_NIBBLES = UID_NUM_BYTES * 2

    NAME_PACK = 'Z*'

    attr_accessible :uid, :name

#    validates_inclusion_of :in => [:uid, :name]
    validates_format_of :uid, with: /\A[a-z0-9]{12}\Z/
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
    # 2. Database.
    # 3. Resource cache (on disk).
    # 4. Gives the default object.
    #
    # == Parameters
    # :uid:  [String]
    def self.load(uid)
      if uid == default.uid
        default
      else
        where(uid: uid).first || default
      end
    end

    def self.import(uid, file_name)
      resource = if File.exist? file_name
        File.open(file_name, "rb") do |file|
          generate(data: file.read, uid: uid)
        end
      else
        default # Failed to load...meh!
      end

      resource.image # Force caching of the image.

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

    # - binary data, where uid is unknown (:data)
    # - binary data along with a uid, such as when read from a disk (:data, :uid)
    # - attributes (:att1..:attN)
    def self.generate(options = {})
      if options[:data]
        options = attributes_from_data(options[:data], { uid: options[:uid] })
      elsif options.empty?
        options = default_attributes(options)
      end

      image = options[:image]
      options.delete image
      created = new(options)
      created.recalculate_uid unless created.uid
      created.cache_image(image) if image
      created.save!
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

    def recalculate_uid
      self.uid = calculate_uid
    end

    def calculate_uid
      Digest::SHA1.hexdigest(to_binary)[0...UID_NUM_NIBBLES]
    end

    def ==(other)
      other.class == self.class and other.uid == uid
    end

    def to_binary
      [name].pack(NAME_PACK)
    end
  end
end