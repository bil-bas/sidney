# encoding: utf-8

begin
  require 'rubygems'
  gem 'chingu'
  #gem 'gglib'

  #gem 'ffi-opengl'
  #gem 'texplay'
rescue LoadError => ex
  STDERR.puts ex
end

#require 'profile'

require 'chingu'
#require 'gglib'
require 'texplay'
#require 'ffi-opengl'
#include Gl, Glu, Glut

include Gosu
include Chingu
#include GGLib

require 'grid'

# HACK to prevent Texplay completely grinding the system to a halt!
#module TexPlay
#   alias_method :force_refresh_cache, :refresh_cache
#   def refresh_cache
#     # Do nothing.
#   end
#end

module ZOrder
  BACKGROUND = -1 # Tiles
  FIRST_OBJECT = 0 # Objects are at z = 0...100000

  GRID, GUI, DIALOG, DRAGGING, FPS, CURSOR = (100001..100006).to_a
end

require 'fps_display'
require 'cursor'
require 'tile'
require 'grid_overlay'

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

    #width, height, full_screen = 640, 480, true
    #width, height, full_screen = Gosu::screen_width, Gosu::screen_height, true

    super(width, height, full_screen)
    
    p [self.width, self.height]
    retrofy

    self.caption = "Sidney"

    self.input = {
      :escape => :exit,
      :f1 => :debug_mode,
      :f => lambda { @fps.visible? ? @fps.hide! : @fps.show! },
    }      

    @cursor = Cursor.create
    @fps = FPSDisplay.new(0, 0)    

    #create_gui

    push_game_state(EditScene)
    #push_game_state(PencilTool)

    nil
  end

  def create_gui
    $textbox = GGLib::TextBox.new("textbox1", 500, 100, 12, GGLib::Themes::Rubygoo)
  end

  def debug_mode
    push_game_state(GameStates::Debug.new(nil))
    
    nil
  end

  def draw
    super

    @fps.draw
  end

  def exit
    close

    nil
  end
end

class Scenery < GameObject
  trait :retrofy

  def dragging?; @dragging; end

  def initialize(options = {})
    super({:center_y => 1}.merge(options))
    #image.force_refresh_cache
  end

  def setup
    @dragging = false
    @z = 0
    nil
  end

  def update(z)
    self.zorder = if @dragging
      ZOrder::DRAGGING
    else
      (self.y * 256) + z
    end

    nil
  end

  def draw(x, y)
    image.draw((self.x - self.width * center_x) + x, (self.y - self.height * center_y) + y, zorder)
  end

  def hit?(x, y)
    pixel = image.get_pixel(x - self.x + (center_x * image.width),
             y - self.y + (center_y * image.height))

    pixel and pixel[3] != 0
  end

  # Set a pixel within our image using image co-ordinates.
  def set_pixel(x, y, color)
    image.pixel(x, y, :color => color)
  end

  # Set the pixel at screen location.
  def set_screen_pixel(x, y, color)
    set_pixel(x - self.x + (center_x * image.width),
               y - self.y + (center_y * image.height), color)

  end

  def show_hide
    visible? ? hide! : show!
    
    nil
  end
end

class PencilTool < GameState

end

class EditScene < GameState
  def initialize
    super

    @grid = Grid.new(($window.height / 240).floor)

    self.input = {
      :left_mouse_button => :left_mouse_button,
      :released_left_mouse_button => :released_left_mouse_button,
      :holding_left_mouse_button => :holding_left_mouse_button,
      :right_mouse_button => :right_mouse_button,
      :released_right_mouse_button => :released_right_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :g => lambda { @grid.toggle_overlay },
      :wheel_up => lambda { @grid.scale *= 2 },
      :wheel_down => lambda { @grid.scale /= 2 },
    }

    nil
  end

  def left_mouse_button


    nil
  end


  def released_left_mouse_button
    #p "release"

    nil
  end

  def holding_left_mouse_button
    x, y = @grid.screen_to_grid($window.cursor.x, $window.cursor.y)
    if object = @grid.hit_object(x, y)
      object.set_screen_pixel(x, y, :red)
    end

    nil
  end

  def right_mouse_button
    nil
  end

  def released_right_mouse_button
    nil
  end

  def holding_right_mouse_button
    x, y = @grid.screen_to_grid($window.cursor.x, $window.cursor.y)
    if object = @grid.hit_object(x, y)
      object.set_screen_pixel(x, y, :blue)
    end

    nil
  end

  def update
    @grid.update

    super
  end

  def draw
    @grid.draw
   
    super    
  end
=begin
  # Called Each time when we enter the game state, use this to reset the gamestate to a "virgin state"
  def setup
  end

  # Called when we leave the game state
  def finalize
  end
=end
end

Game.new.show