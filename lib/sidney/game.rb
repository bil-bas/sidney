# encoding: utf-8

begin
  require 'rubygems'
  gem 'chingu'
rescue LoadError => ex
  STDERR.puts ex
end

# Allow gems to find the bin directory for binary libraries.
ENV['PATH'] = "#{File.join(ROOT_PATH, 'bin')};#{ENV['PATH']}"

#require 'profile'

require 'chingu'
require 'devil'
require 'devil/gosu'
require 'texplay'

include Gosu
include Chingu

# HACK to prevent Texplay completely grinding the system to a halt!
#module TexPlay
#   alias_method :force_refresh_cache, :refresh_cache
#   def refresh_cache
#     # Do nothing.
#   end
#end

module ZOrder
  BACKGROUND = -1 # Tiles
  FIRST_OBJECT = 0 # Objects are at z = 0...1000000

  GRID, GUI, DIALOG, DRAGGING, FPS, CURSOR = (1000001..1000006).to_a
end

require 'fps_display'
require 'gui/cursor'
require 'grid'
require 'states/edit_scene'
require 'gosu/window'

exit if defined?(Ocra)

class Game < Window
  attr_reader :cursor

  # Any larger and Gosu will scale the whole window to fit.
  MAX_HEIGHT = Gosu::screen_width * 0.8
  MAX_WIDTH = Gosu::screen_width * 0.9
  
  protected
  def initialize
    #width, height, full_screen = 640, 480, false
    width, height, full_screen = 960, 720, false
    #width, height, full_screen = 1280, 960, false
    #width, height, full_screen = 800 * 16 / 10, 800, false

    #width, height, full_screen = 640, 480, true
    #width, height, full_screen = Gosu::screen_width, Gosu::screen_height, true

    super(width, height, full_screen)
  end

  def setup
    media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'media'))
    Image.autoload_dirs << File.join(media_dir, 'images')
    Sample.autoload_dirs << File.join(media_dir, 'sounds')

    retrofy

    self.caption = "Sidney"

    self.input = {
      :f => lambda { @fps.toggle },
    }

    @cursor = Cursor.create
    @fps = FPSDisplay.new(0, 0)

    push_game_state(EditScene)

    nil
  end

  def draw
    @fps.draw

    super
  end
end

Game.new.show