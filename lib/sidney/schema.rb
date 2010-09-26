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
  
  create_table :tiles, id: false do |t|
    t.string :uid, limit: uid_length, primary: true

    t.string :name,  null: false
  end

  create_table :tile_layers, id: false do |t|
    t.string :room_id, limit: uid_length, null: false
    t.string :tile_id, limit: uid_length, null: false

    t.integer :x, null: false
    t.integer :y, null: false
    t.boolean :blocked, null: false
  end

  add_index :tile_layers, :room_id
  add_index :tile_layers, :tile_id
  add_index :tile_layers, [:x, :y]

  create_table :rooms, id: false do |t|
    t.string :uid, limit: uid_length, primary: true

    t.string :name, null: false
  end

  create_table :sprites, id: false do |t|
    t.string :uid, limit: uid_length, primary: true

    t.string :name,  null: false

    t.integer :x_offset, null: false
    t.integer :y_offset, null: false
  end

  create_table :state_objects, id: false do |t|
    t.string :uid, limit: uid_length, primary: true
    t.string :name, null: false

    t.integer :x_offset, null: false
    t.integer :y_offset, null: false
    t.boolean :glows, default: false
  end

  create_table :sprite_layers, id: false do |t|
    t.string :state_object_id, limit: uid_length, null: false
    t.string :sprite_id, limit: uid_length, null: false

    t.integer :alpha, null: false
    t.boolean :glows, null: false
    
    t.integer :x, null: false
    t.integer :y, null: false
  end

  add_index :sprite_layers, :sprite_id
  add_index :sprite_layers, :state_object_id

  create_table :state_object_layers, id: false do |t|
    t.string :scene_id, limit: uid_length, null: false
    t.string :state_object_id, limit: uid_length, null: false
    
    t.integer :x, null: false
    t.integer :y, null: false
    t.integer :z, null: false

    t.integer :alpha, null: false
    t.boolean :locked, null: false

    t.integer :speech_offset_x, null: false
    t.integer :speech_offset_y, null: false
    t.boolean :speech_flipped, null: false
    t.boolean :speech_box, null: false
  end

  add_index :state_object_layers, :scene_id
  add_index :state_object_layers, :state_object_id

  create_table :scenes, id: false do |t|
    t.string :uid, limit: uid_length, primary: true
    t.string :name, null: false

    t.string :room_id, null: false
    t.integer :room_alpha, null: false
  end
end