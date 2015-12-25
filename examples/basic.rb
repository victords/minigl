# file: basic.rb
require_relative '../lib/minigl'

# including MiniGL module so we can easily call its classes
include MiniGL

# defining a few constants we will use as window size
WINDOW_WIDTH = 1066
WINDOW_HEIGHT = 600

class MyGame < GameWindow
  def initialize
    # this method is called once when the game begins,
    # here we will initialize everything we need from start

    # creating a wide windowed game
    super WINDOW_WIDTH, WINDOW_HEIGHT, false
  end

  def update
    # this method is called for every update in the game logics
    # as events, positions, status variables,  calculations, etc.
  end

  def draw
    # this method is called after updates for refreshing the game graphics
  end
end

game = MyGame.new
game.show