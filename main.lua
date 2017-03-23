local ball = require "ball"
local platform = require "platform"
local bricks = require "bricks"
local walls = require "walls"
local levels = require "levels"
local collisions = require "collisions"

function love.load()
  bricks.construct_level(levels.sequence[levels.current_level])
  walls.construct_walls()
end

function love.update(dt)
  ball.update(dt)
  platform.update(dt)
  bricks.update(dt)
  walls.update(dt)
  collisions.resolve_collisions(ball, platform, walls, bricks)
  levels.goto_next_level(bricks, ball)
end

function love.draw()
  ball.draw()
  platform.draw()
  bricks.draw()
  walls.draw()
  if levels.gamefinished then
    love.graphics.printf("Whasdf\n" ..
      "asdf", 300, 250, 200, "center"
    )
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end

function love.keyreleased(key, code)
  if key == 'escape' then
    love.event.quit()
  end
end
