# encoding: utf-8

begin
  begin
    require 'minigems'
  rescue LoadError => ex
    require 'rubygems'
  end
rescue LoadError => ex
  STDERR.puts ex
end

# Allow gems to find the bin directory for binary libraries.
ENV['PATH'] = "#{File.join(ROOT_PATH, 'bin')};#{ENV['PATH']}"

#require 'profile'

# Gems

begin; gem 'activerecord'; rescue Exception => ex; end
require 'active_record'
begin; gem 'i18n'; rescue Exception => ex; end
require 'i18n'
begin; gem 'chingu'; rescue Exception => ex; end
require 'chingu'
require 'devil'
require 'devil/gosu'
require 'texplay'
TexPlay.set_options(caching: false) # Generally, we don't want caching.

I18n.load_path << Dir[File.join(ROOT_PATH, 'config', 'locales', '*.yml')]

include Gosu
include Chingu

module Sidney
# Z-order of all elements of the game.
module ZOrder
  BACKGROUND = -1 # Tiles
  FIRST_OBJECT = 0 # Objects are at z = 0...1000000

  GUI, DRAGGING, GRID_OVERLAY, DIALOG, FPS, CURSOR = (1000001..1000007).to_a
end

require_relative 'log'
require_relative 'database'
require_relative 'fps_display'
require_relative 'gui/cursor'
require_relative 'grid'
require_relative 'states/edit_scene'
require_relative 'resources'

# Main game window.
class Game < Window
  include Log
  attr_reader :cursor

  # Any taller and Gosu will scale the whole window to fit.
  MAX_HEIGHT = Gosu::screen_width * 0.8
  # Any wider and Gosu will scale the whole window to fit.
  MAX_WIDTH = Gosu::screen_width * 0.9
  
  protected
  def initialize(full_screen)
    #width, height = 400, 300
    width, height = 800, 600
    #width, height = 1200, 900
    #width, height = 800 * 16 / 10, 800

    #width, height = 800, 600
    #width, height = Gosu::screen_width, Gosu::screen_height

    super(width, height, full_screen)
    log.info { "Opened window" }
  end

  def setup
    media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'media'))
    Image.autoload_dirs << File.join(media_dir, 'images')
    Sample.autoload_dirs << File.join(media_dir, 'sounds')

    retrofy

    self.caption = t 'window_title'

    on_input(:f) { @fps.toggle if holding_control? }

    @cursor = Cursor.create
    @fps = FPSDisplay.new(0, 0)

    push_game_state(EditScene)
   
    nil
  end

  protected
  def draw
    @fps.draw

    super
  end

  public
  def t(*args); I18n.t(*args); end

  public
  def draw_box(x, y, width, height, z, border_color = nil, fill_color = nil)
    if fill_color
      draw_quad(x, y, fill_color,
                        x + width, y, fill_color,
                        x + width, y + height, fill_color,
                        x, y + height, fill_color, z)
    end

    if border_color
      draw_line(x, y, border_color, x, y + height, border_color, z) # left
      draw_line(x, y, border_color, x + width, y, border_color, z) # top
      draw_line(x + width, y, border_color, x + width, y + height,  border_color, z) # right
      draw_line(x, y + height, border_color, x + width, y + height,  border_color, z) # bottom
    end

    nil
  end

  public
  def holding_shift?
    holding_any? :left_shift, :right_shift
  end

  public
  def holding_control?
    holding_any? :left_control, :right_control
  end

  public
  def holding_alt?
    holding_any? :left_alt, :right_alt
  end

  public
  def self.run
    return if defined? Ocra

    full_screen = case ARGV
                    when []
                      false
                    when ["--full-screen"], ["-f"]
                      true
                    else
                      return "Usage:\n  #{File.basename($0)} [--full-screen]"
                      nil
                  end

    new(full_screen).show
  end
end
end

