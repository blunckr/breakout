local bricks = {}
bricks.brick_width = 50
bricks.brick_height = 30
bricks.top_left_x = 70
bricks.top_left_y = 50
bricks.horizontal_margin = 10
bricks.vertical_margin = 15
bricks.current_level_bricks = {}

function bricks.update(dt)
  if #bricks.current_level_bricks == 0 then
    bricks.no_more_bricks = true
  else
    for _, brick in pairs(bricks.current_level_bricks) do
      bricks.update_brick(brick)
    end
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

function bricks.construct_level(layout)
  bricks.no_more_bricks = false
  for row_index, row in pairs(layout) do
    for col_index, bricktype in pairs(row) do
      if bricktype ~= 0 then
        local x = bricks.top_left_x +
          (col_index - 1) *
          (bricks.brick_width + bricks.horizontal_margin)
        local y = bricks.top_left_y +
          (row_index - 1) *
          (bricks.brick_height + bricks.vertical_margin)
        local brick = bricks.new_brick(x, y)
        table.insert(bricks.current_level_bricks, brick)
      end
    end
  end
end

function bricks.brick_hit_by_ball(i)
  table.remove(bricks.current_level_bricks, i)
end

return bricks
