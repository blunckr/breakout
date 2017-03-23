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

function ball.rebound(shift_ball_x, shift_ball_y)
  local min_shift = math.min(
    math.abs(shift_ball_x),
    math.abs(shift_ball_y)
  )
  if math.abs(shift_ball_x) == min_shift then
    shift_ball_y = 0
  else
    shift_ball_x = 0
  end
  ball.position_y = ball.position_y + shift_ball_y
  ball.position_x = ball.position_x + shift_ball_x
  if shift_ball_x ~= 0 then
    ball.speed_x = -ball.speed_x
  end
  if shift_ball_y ~= 0 then
    ball.speed_y = -ball.speed_y
  end
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

function platform.bounce_off_wall(shift_x)
  platform.position_x = platform.position_x + shift_x
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

function bricks.brick_hit_by_ball(i)
  table.remove(bricks.current_level_bricks, i)
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

local collisions = {}

function collisions.resolve_collisions()
  collisions.ball_platform_collision(ball, platform)
  collisions.ball_walls_collision(ball, walls)
  collisions.ball_bricks_collision(ball, bricks)
  collisions.platform_walls_collision(platform, walls)
end

function collisions.rectangles_overlap(a, b)
  local overlap = false
  local shift_b_x, shift_b_y = 0, 0
  if not(
    a.x + a.width < b.x or
    b.x + b.width < a.x or
    a.y + a.height < b.y or
    b.y + b.height < a.y
  ) then
    overlap = true
    if (a.x + a.width / 2 ) < (b.x + b.width / 2) then
      shift_b_x = (a.x + a.width) - b.x
    else
      shift_b_x = a.x - (b.x + b.width)
    end
    if (a.y + a.height / 2) < (b.y + b.height / 2) then
      shift_b_y = (a.y + a.height) - b.y
    else
      shift_b_y = a.y - (b.y + b.height)
    end
  end
  return overlap, shift_b_x, shift_b_y
end

function collisions.ball_platform_collision(ball, platform)
  local overlap, shift_ball_x, shift_ball_y
  local a = {
    x = platform.position_x,
    y = platform.position_y,
    width = platform.width,
    height = platform.height
  }

  local b = {
    x = ball.position_x - ball.radius,
    y = ball.position_y - ball.radius,
    width = 2 * ball.radius,
    height = 2 * ball.radius
  }
  overlap, shift_ball_x, shift_ball_y =
    collisions.rectangles_overlap(a, b)
  if overlap then
    ball.rebound(shift_ball_x, shift_ball_y)
  end
end

function collisions.ball_bricks_collision(ball, bricks)
  local b = {
    x = ball.position_x - ball.radius,
    y = ball.position_y - ball.radius,
    width = 2 * ball.radius,
    height = 2 * ball.radius
  }

  for i, brick in pairs(bricks.current_level_bricks) do
    local a = {
      x = brick.position_x,
      y = brick.position_y,
      width = brick.width,
      height = brick.height
    }
    local overlap, shift_ball_x, shift_ball_y =
      collisions.rectangles_overlap(a, b)
    if overlap then
      ball.rebound(shift_ball_x, shift_ball_y)
      bricks.brick_hit_by_ball(i)
    end
  end
end

function collisions.ball_walls_collision(ball, walls)
  local b = {
    x = ball.position_x - ball.radius,
    y = ball.position_y - ball.radius,
    width = 2 * ball.radius,
    height = 2 * ball.radius
  }

  for _, wall in pairs(walls.current_level_walls) do
    local a = {
      x = wall.position_x,
      y = wall.position_y,
      width = wall.width,
      height = wall.height
    }
    local overlap, shift_ball_x, shift_ball_y =
      collisions.rectangles_overlap(a, b)
    if overlap then
      ball.rebound(shift_ball_x, shift_ball_y)
    end
  end
end

function collisions.platform_walls_collision(platform, walls)
  local b = {
    x = platform.position_x,
    y = platform.position_y,
    width = platform.width,
    height = platform.height
  }

  for _, wall in pairs(walls.current_level_walls) do
    local a = {
      x = wall.position_x,
      y = wall.position_y,
      width = wall.width,
      height = wall.height
    }

    local overlap, shift_x, _ =
      collisions.rectangles_overlap(a, b)
    if overlap then
      platform.bounce_off_wall(shift_x)
    end
  end
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
  collisions.resolve_collisions()
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

function love.keyreleased(key, code)
  if key == 'escape' then
    love.event.quit()
  end
end
