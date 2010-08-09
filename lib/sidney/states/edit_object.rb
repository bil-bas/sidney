require 'gui/history'

class EditObject < GameState
  MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = 416, 416

  protected
  def grid
    game_state_manager.previous.grid
  end

  protected
  def cursor
    $window.cursor
  end

  protected
  def initialize(object)
    @object = object

    super  
  end

  public
  def setup
    @object.hide!

    self.input = {
      :holding_left_mouse_button => :holding_left_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :released_escape => lambda { game_state_manager.pop },
    }

    @image = TexPlay.create_image($window, MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)
    @image.splice(@object.image, @object.x - @object.width * 0.5, @object.y - @object.height)

    nil
  end

  protected
  def holding_left_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @image.set_pixel(x, y, :color => :red)
    end

    nil
  end

  protected
  def holding_right_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @image.set_pixel(x, y, :color => 0x00000000)
    end

    nil
  end

  public
  def draw
    game_state_manager.previous.draw
    rect = grid.rect
    $window.draw_box(rect.x, rect.y, rect.right, rect.bottom, 100000, nil, 0xa0000000)

    $window.translate(rect.x, rect.y) do
      $window.clip_to(rect.x, rect.y, rect.width, rect.height) do
        $window.scale(grid.scale) do
          @image.draw(grid.offset_x, grid.offset_y, 100001)
        end
      end
    end
  end

  public
  def finalize
    #@object.image = @image
    @object.show!
  end
end