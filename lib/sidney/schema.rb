# encoding: utf-8

require 'active_record'

require_relative 'database'

# scene
#   has many state_objects (through object_layer)
#       has many sprites (through sprite_layer)
#   has a room
#       has many tiles (through tile_layer)
#
ActiveRecord::Schema.define do
  uid_length = 12

  # Tiles.
  create_table :tiles, id: false do |t|
    t.string :id, limit: uid_length, null: false
    t.primary_key :id

    t.string :name,  null: false
  end

  add_index :tiles, :id, unique: true

  # TileLayers (Room->Tiles)
  create_table :tile_layers, id: false do |t|
    t.string :room_id, limit: uid_length, null: false
    t.string :tile_id, limit: uid_length, null: false

    t.integer :x, :y, null: false
    t.boolean :blocked, null: false
  end

  add_index :tile_layers, :room_id
  add_index :tile_layers, :tile_id
  add_index :tile_layers, [:x, :y]

  # Rooms.
  create_table :rooms, id: false do |t|
    t.string :id, limit: uid_length, null: false
    t.primary_key :id

    t.string :name, null: false
  end

  add_index :rooms, :id, unique: true

  # Sprites.
  create_table :sprites, id: false do |t|
    t.string :id, limit: uid_length, null: false
    t.primary_key :id

    t.string :name,  null: false

    t.integer :x_offset, :y_offset, default: 0
  end

  add_index :sprites, :id, unique: true

  # StateObjects.
  create_table :state_objects, id: false do |t|
    t.string :id, limit: uid_length, null: false
    t.primary_key :id

    t.string :name, null: false

    t.integer :x_offset, :y_offset, default: 0

    t.boolean :glows, default: false
  end

  add_index :state_objects, :id, unique: true

  # SpriteLayers (StateObject->Sprites)
  create_table :sprite_layers, id: false do |t|
    t.string :state_object_id, limit: uid_length, null: false
    t.string :sprite_id, limit: uid_length, null: false

    t.integer :alpha, null: false
    t.boolean :glows, null: false
    
    t.integer :x, :y, null: false
  end

  add_index :sprite_layers, :sprite_id
  add_index :sprite_layers, :state_object_id

  # StateObjectLayers (Scene->StateObjects)
  create_table :state_object_layers, id: false do |t|
    t.string :scene_id, limit: uid_length, null: false
    t.string :state_object_id, limit: uid_length, null: false
    
    t.integer :x, :y, :z, null: false

    t.integer :alpha, null: false
    t.boolean :locked, null: false

    t.integer :speech_offset_x, :speech_offset_y, null: false
    t.boolean :speech_flipped, null: false
    t.boolean :speech_box, null: false
  end

  add_index :state_object_layers, :scene_id
  add_index :state_object_layers, :state_object_id

  # Scenes.
  create_table :scenes, id: false do |t|
    t.string :id, limit: uid_length, null: false
    t.primary_key :id

    t.string :name, null: false

    t.string :room_id, null: false
    t.string :tint, null: false
  end

  add_index :scenes, :id, unique: true
end