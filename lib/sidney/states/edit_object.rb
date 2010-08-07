require 'history'

class ObjectBeingEdited < GameObject
  MAX_IMAGE_SIZE = 1022
  
  trait :retrofy

  def initialize(object)
    original = object.image
    image = TexPlay.create_image($window, MAX_IMAGE_SIZE, MAX_IMAGE_SIZE)
    image.rect(0, 0, 104+original.width, 104+original.height, :fill => true, :texture => original)
    image.rect(0, 0, 100, 100, :fill => true, :color => :red)
    super(:image => image, :x => 4, :y => 4, :center_x => 0, :centre_y => 0, :zorder => 1000000, :factor_x => object.factor_x, :factor_y => object.factor_y)
  end
end

class EditObject < GameState
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
    super
    
    @original_object = object
    @original_object.hide!
    
    @object_being_edited = ObjectBeingEdited.new(@original_object)

    self.input = {
      :holding_left_mouse_button => :holding_left_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :released_escape => lambda { game_state_manager.pop },
    }
  end

  protected
  def holding_left_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @object_being_edited.image.set_pixel(x, y, :color => :red)
    end

    nil
  end

  protected
  def holding_right_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @object_being_edited.image.set_pixel(x, y, :color => :blue)
    end

    nil
  end

  public
  def draw
    game_state_manager.previous.draw
    rect = grid.rect
    $window.draw_box(rect.x, rect.y, rect.right, rect.bottom, 100000, nil, 0xa0000000)
    @object_being_edited.draw
  end

  public
  def finalize
    @original_object.show!
  end
end