local ball = {}
ball.position_x = 300
ball.position_y = 300
ball.speed_x = 300
ball.speed_y = 300
ball.radius = 10

function ball.update(dt)
  ball.position_x = ball.position_x + ball.speed_x * dt
  ball.position_y = ball.position_y + ball.speed_y * dt
end

function ball.draw()
  local segments_in_circle = 16
  love.graphics.circle(
    'line',
    ball.position_x,
    ball.position_y,
    ball.radius,
    segments_in_circle
  )
end

local platform = {}
platform.position_x = 500
platform.position_y = 500
platform.speed_x = 300
platform.width = 70
platform.height = 20

function platform.update(dt)
  if love.keyboard.isDown("right") then
    platform.position_x = platform.position_x + (platform.speed_x * dt)
  end

  if love.keyboard.isDown("left") then
    platform.position_x = platform.position_x - (platform.speed_x * dt)
  end
end

function platform.draw()
  love.graphics.rectangle(
    'line',
    platform.position_x,
    platform.position_y,
    platform.width,
    platform.height
  )
end

local bricks = {}
bricks.brick_width = 50
bricks.brick_height = 30
bricks.rows = 8
bricks.columns = 11
bricks.top_left_x = 70
bricks.top_left_y = 50
bricks.horizontal_margin = 10
bricks.vertical_margin = 15
bricks.current_level_bricks = {}

function bricks.update(dt)
  for _, brick in pairs(bricks.current_level_bricks) do
    bricks.update_brick(brick)
  end
end

function bricks.update_brick(brick)
end

function bricks.draw()
  for _, brick in pairs(bricks.current_level_bricks) do
    bricks.draw_brick(brick)
  end
end

function bricks.draw_brick(brick)
  love.graphics.rectangle(
    'line',
    brick.position_x,
    brick.position_y,
    brick.width,
    brick.height
  )
end

function bricks.new_brick(position_x, position_y, width, height)
  return({
    position_x = position_x,
    position_y = position_y,
    width = width or bricks.brick_width,
    height = height or bricks.brick_height,
  })
end

function bricks.construct_level()
  for row = 1, bricks.rows do
    for col = 1, bricks.columns do
      local x = bricks.top_left_x +
        (col - 1) *
        (bricks.brick_width + bricks.horizontal_margin)
      local y = bricks.top_left_y +
        (row - 1) *
        (bricks.brick_height + bricks.vertical_margin)
      local brick = bricks.new_brick(x, y)
      table.insert(bricks.current_level_bricks, brick)
    end
  end
end

local walls = {}
walls.current_level_walls = {}
walls.wall_thickness = 20

function walls.update_wall(wall)
end

function walls.update(dt)
  for _, wall in pairs(walls.current_level_walls) do
    walls.update_wall(wall)
  end
end

function walls.draw_wall(wall)
  love.graphics.rectangle(
    'line',
    wall.position_x,
    wall.position_y,
    wall.width,
    wall.height
  )
end

function walls.draw()
  for _, wall in pairs(walls.current_level_walls) do
    walls.draw_wall(wall)
  end
end

function walls.new_wall(position_x, position_y, width, height)
  return({
    position_x = position_x,
    position_y = position_y,
    width = width,
    height = height
  })
end

function walls.construct_walls()
  local left = walls.new_wall(
    0,
    0,
    walls.wall_thickness,
    love.graphics.getHeight()
  )
  local right = walls.new_wall(
    love.graphics.getWidth() - walls.wall_thickness,
    0,
    walls.wall_thickness,
    love.graphics.getHeight()
  )
  local top = walls.new_wall(
    0,
    0,
    love.graphics.getWidth(),
    walls.wall_thickness
  )
  local bottom = walls.new_wall(
    0,
    love.graphics.getHeight() - walls.wall_thickness,
    love.graphics.getWidth(),
    walls.wall_thickness
  )

  walls.current_level_walls["left"] = left
  walls.current_level_walls["right"] = right
  walls.current_level_walls["top"] = top
  walls.current_level_walls["bottom"] = bottom
end

function love.load()
  bricks.construct_level()
  walls.construct_walls()
end

function love.update(dt)
  ball.update(dt)
  platform.update(dt)
  bricks.update(dt)
  walls.update(dt)
end

function love.draw()
  ball.draw()
  platform.draw()
  bricks.draw()
  walls.draw()
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
