-- Created by Andre Vallestero
-- Licensed under GNU AGPLv3+

NORTH = 0	-- z positive
EAST = 1		-- x positive
SOUTH = 2	-- z negative
WEST = 3		-- x negative

UP = 4		-- y positive
DOWN = 5		-- y negative

DIM_X = 0
DIM_Y = 1
DIM_Z = 2

print("Make sure the top 4 slots are have a block of filter material!")
print("(cobble, andesite, diorite, granite)")

print("To guarantee space for an item, place one of it in the bottom 3 rows")

HOME_X = 0
print("What is my Y coord?")
HOME_Y = read()
HOME_Z = 0

-- Internal location system
x = 0
y = HOME_Y
z = 0
azmth = NORTH
going_home = false

function is_valuable(data)
	return 
		string.find(data.name:lower(), "ore")
		and not string.find(data.name:lower(), "explore")
end

function main()
	local prev_vert_dir = DOWN
	mine_move_chex_to(HOME_X, 6, HOME_Z)
	local rep_xz = false

	-- Init x
	local next_x = -4
	local count_up_x = -2
	local max_count_x = 1
	local step_x = 4
	
	-- Init y
	local count_y = 1
	local next_y = 0
	
	-- Init z
	local next_z = 0
	local count_up_z = -1
	local max_count_z = 1
	local step_z = 4
	
	while true do
		-- Generate x
		if not rep_xz then
			if count_up_x < 0 then
				next_x = next_x + step_x
			elseif count_up_x > max_count_x then
				step_x = -step_x
				max_count_x = max_count_x + 1
				count_up_x = -max_count_x
				next_x = next_x + step_x
			end
			count_up_x = count_up_x + 1
		end
		
		-- Generate y
		next_y = count_y > 1 and 12 or 6
		count_y = (count_y + 1) % 4
		
		-- Generate Z
		if not rep_xz then
			if count_up_z < 0 then
				next_z = next_z + step_z
			elseif count_up_z >= max_count_z then
				step_z = -step_z
				max_count_z = max_count_z + 1
				count_up_z = -max_count_z
				next_z = next_z + step_z
			end
			count_up_z = count_up_z + 1
		end
		
		rep_xz = not rep_xz
		
		mine_move_chex_to(next_x, next_y, next_z)
	end
end

function mine_move_chex_to(target_x, target_y, target_z)
	print("mimochexing to:", target_x, target_y, target_z)
	
	local dist_x = target_x-x
	local dist_y = target_y-y
	local dist_z = target_z-z
	
	local step_x = dist_x > 0 and 1 or -1
	local step_y = dist_y > 0 and 1 or -1
	local step_z = dist_z > 0 and 1 or -1
	
	-- Y is closest axis, do it first
	if math.min(dist_x, dist_y, dist_z) == dist_y then
		mine_move_chex_step(target_y, step_y, DIM_Y)
		if math.abs(dist_x) < math.abs(dist_z) then
			mine_move_chex_step(target_x, step_x, DIM_X)
			mine_move_chex_step(target_z, step_z, DIM_Z)
		else
			mine_move_chex_step(target_z, step_z, DIM_Z)
			mine_move_chex_step(target_x, step_x, DIM_X)
		end
	-- Y is furthest axis, do it last
	elseif math.max(dist_x, dist_y, dist_z) == dist_y then
		if math.abs(dist_x) < math.abs(dist_z) then
			mine_move_chex_step(target_x, step_x, DIM_X)
			mine_move_chex_step(target_z, step_z, DIM_Z)
		else
			mine_move_chex_step(target_z, step_z, DIM_Z)
			mine_move_chex_step(target_x, step_x, DIM_X)
		end
		mine_move_chex_step(target_y, step_y, DIM_Y)
	-- Do Y in between
	else
		if math.abs(dist_x) < math.abs(dist_z) then
			mine_move_chex_step(target_x, step_x, DIM_X)
			mine_move_chex_step(target_y, step_y, DIM_Y)
			mine_move_chex_step(target_z, step_z, DIM_Z)
		else
			mine_move_chex_step(target_z, step_z, DIM_Z)
			mine_move_chex_step(target_y, step_y, DIM_Y)
			mine_move_chex_step(target_x, step_x, DIM_X)
		end
	end
end

function mine_move_chex_step(target, step, dim)
	local i = -1
	if dim == DIM_X then
		i = x
	elseif dim == DIM_Y then
		i = y
	elseif dim == DIM_Z then
		i = z
	end
	for next_pos=i+step,target,step do
		if dim == DIM_X and target ~= x then
			goto(next_pos, y, z)
			chexcavate_roll()
		elseif dim == DIM_Y and target ~= y then
			goto(x, next_pos, z)
			if step > 0 then 
				chexcavate_yaw_dir(UP)
			else
				chexcavate_yaw_dir(DOWN)
			end
		elseif dim == DIM_Z and target ~= z then
			goto(x, y, next_pos)
			chexcavate_roll()
		end
	end
end

-- Check the 4 blocks revolving the horizontal axis and excavate
-- Useful when moving forward and back
function chexcavate_roll()
	if chexcavate() then return end		-- Check in front
	if chexcavate_up() then return end	-- Check above
	if chexcavate_down() then return end	-- Check below
	turn_right()						-- Check right
	if chexcavate() then return end
	turn_left()						-- Check left
	turn_left()
	if chexcavate() then return end
end

-- Check the 4 blocks revolving the vertical axis and excavate
-- Useful when moving up and down
function chexcavate_yaw_dir(dir)
	if dir == UP then
		if chexcavate_up() then return end	-- Check above
	elseif dir == DOWN then
		if chexcavate_down() then return end	-- Check below
	end
	if chexcavate() then return end	-- Check in front
	turn_right()	-- Check right
	if chexcavate() then return end
	turn_right()	-- Check back
	if chexcavate() then return end
	turn_right()	-- Check left
	if chexcavate() then return end
end

-- Recursively follow valuable vein forward
function chexcavate()
	local success, data = turtle.inspect()
	if success and is_valuable(data) then
		turtle.dig()
		forward()
		chexcavate_roll()
		return true
	end
	return false
end

-- Recursively follow valuable vein up
function chexcavate_up()
	local success, data = turtle.inspectUp()
	if success and is_valuable(data) then
		turtle.digUp()
		up()
		chexcavate_yaw_dir(UP)
		return true
	end
	return false
end

-- Recursively follow valuable vein down
function chexcavate_down()
	local success, data = turtle.inspectDown()
	if success and is_valuable(data) then
		turtle.digDown()
		down()
		chexcavate_yaw_dir(DOWN)
		return true
	end
	return false
end

function goto(target_x, target_y, target_z)
	local dist_x = target_x-x
	local dist_z = target_z-z
	
	if math.abs(dist_x) < math.abs(dist_z) then
		move_x(dist_x)
		move_z(dist_z)
	else
		move_z(dist_z)
		move_x(dist_x)
	end
	
	move_y(target_y-y)
end

function move_x(dist_x)
	if dist_x == 0 then return end
	
	turn(dist_x > 0 and EAST or WEST)
	bore(math.abs(dist_x))
end

function move_z(dist_z)
	if dist_z == 0 then return end
	
	turn(dist_z > 0 and NORTH or SOUTH)
	bore(math.abs(dist_z))
end

function move_y(dist_y)
	if dist_y == 0 then return end
		
	local is_up = dist_y > 0
	local detect_func, dig_func, move_func = 
		is_up and turtle.detectUp or turtle.detectDown,
		is_up and turtle.digUp or turtle.digDown,
		is_up and up or down
	
	for i=1,math.abs(dist_y) do
		while detect_func() do
			if not dig_func() then
				going_home = true
				print("Could not break block, going home")
				goto(HOME_X, HOME_Y, HOME_Z)
				print("Program complete")
				error()
			end
			
		end
		move_func()
	end
end

function turn(heading)
	if heading == azmth then return end
	if math.abs(heading - azmth) == 2 then
		turn_left()
		turn_left()
	elseif (heading < azmth or (heading == WEST and  azmth == NORTH)) and not (heading == NORTH and azmth == WEST) then
		turn_left()
	else
		turn_right()
	end
end

-- Move forward while mining
function bore(dist)
	for _=1,dist do
		while turtle.detect() do
			if not turtle.dig() then
				if going_home == true then
					print("Could not navigate home, surfacing")
					goto(x, HOME_Y, y)
					print("Program complete")
					error()
				end
				going_home = true
				print("Could not break block, going home")
				goto(HOME_X, HOME_Y, HOME_Z)
				print("Program complete")
				error()
			end
		end
		forward()
	end
end

function forward()
	go_home_if_need()
	turtle.forward()
	if azmth == NORTH then
		z = z + 1
	elseif azmth == EAST then
		x = x + 1
	elseif azmth == SOUTH then
		z = z - 1
	elseif azmth == WEST then
		x = x - 1
	end
end

function up()
	go_home_if_need()
	turtle.up()
	y = y + 1
end

function down()
	go_home_if_need()
	turtle.down()
	y = y - 1
end

function turn_right()
	turtle.turnRight()
	azmth = (azmth + 1) % 4
end

function turn_left()
	turtle.turnLeft()
	azmth = (azmth - 1) % 4
end

function go_home_if_need()
	if going_home then
		return
	end

	-- Drop garbage before inventory check
	for i=1,4 do
		if turtle.getItemCount(i) > 63 then
			turtle.select(i)
			turtle.drop(8)
		end
	end

	-- If inventory full (no empty slots and at least one slot is full)
	local some_full_stack = false
	local no_empty_slots = true
	for i=1,16 do
		if turtle.getItemCount(i) == 0 then
			no_empty_slots = false
			break
		end
		if turtle.getItemSpace(i) == 0 then
			some_full_stack = true
		end
	end
	if some_full_stack and no_empty_slots then
		going_home = true
		print("Inventory full, going home")
		goto(HOME_X, HOME_Y, HOME_Z)
		print("Program complete")
		error()
	end

	-- If fuel almost empty
	local home_dist = math.abs(x-HOME_X) + math.abs(y-HOME_Y) + math.abs(z-HOME_Z)
	if turtle.getFuelLevel() - home_dist <= 50 then
		going_home = true
		print("Fuel almost empty, going home")
		goto(HOME_X, HOME_Y, HOME_Z)
		print("Program complete")
		error()
	end
end

main()