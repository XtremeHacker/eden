-- tree/init.lua

trees = {}
trees.registered = {}

local path = minetest.get_modpath("trees").."/schematics"

---
--- Prerequisites
---

-- [item] Stick
minetest.register_craftitem("trees:stick", {
	description = "Stick",
	inventory_image = "trees_stick.png",
})

-- [recipe] Stick
minetest.register_craft({
	type = "shapeless",
	output = "trees:stick 4",
	recipe = {"group:plank"},
})

---
--- API
---

-- [function] Register tree
function trees.register(name, def)
	def.items = {
		sapling = "trees:"..name,
		large = "trees:"..name.."_large",
		trunk = "trees:"..name.."_trunk",
		log = "trees:"..name.."_log",
		plank = "trees:"..name.."_plank",
		leaf = "trees:"..name.."_leaf",
		wall = "trees:"..name.."_wall",
		fence = "trees:"..name.."_fence",
	}
	local items = def.items

	-- Sapling
	minetest.register_node(items.sapling, {
		tree_type = name,
		description = def.basename.." Sapling",
		drawtype = "plantlike",
		inventory_image = def.sapling,
		wield_image = def.sapling,
		tiles = {def.sapling},
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		on_timer = trees.grow,
		on_construct = function(pos)
			minetest.get_node_timer(pos):start(math.random(def.time.start_min, def.time.start_max))
		end,
		selection_box = {
			type = "fixed",
			fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
		},
		groups = {dig_immediate = 3, flammable = 2, sapling = 1},
	})

	-- Normal (large)
	minetest.register_node(items.large, {
		tree_type = name,
		description = "Large "..def.basename.." Log",
		tiles = {def.center, def.sides},
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1},
		on_place = minetest.rotate_node,
	})

	-- Trunk
	minetest.register_node(items.trunk, {
		tree_type = name,
		description = def.basename.." Trunk",
		tiles = {def.center, def.sides},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1, not_in_creative_inventory = 1},
		drop = "trees:"..name.."_large",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- Base
				{-0.1875, -0.5, -0.375, 0.25, 0.375, -0.25}, -- NodeBox3
				{0.25, -0.5, -0.1875, 0.375, 0.1875, 0.1875}, -- NodeBox4
				{-0.375, -0.5, -0.25, -0.25, 0.25, 0.1875}, -- NodeBox5
				{-0.1875, -0.5, 0.25, 0.1875, 0.4375, 0.375}, -- NodeBox6
				{-0.0625, -0.5, 0.375, 0.125, 0, 0.4375}, -- NodeBox7
			},
		},
	})

	-- Log
	minetest.register_node(items.log, {
		tree_type = name,
		description = def.basename.." Log",
		tiles = {def.center, def.sides},
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, log = 1, not_in_creative_inventory = 1},
		drop = "trees:"..name.."_large",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed         = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
			connect_front = {-0.125, -0.125, -0.5, 0.1875, 0.1875, -0.25},
			connect_back  = {-0.1875, -0.125, 0.1875, 0.1875, 0.1875, 0.5},
			connect_left  = {-0.5, -0.125, -0.125, -0.25, 0.1875, 0.125},
			connect_right = {0.25, -0.125, -0.125, 0.5, 0.1875, 0.1875},
		},
		connects_to = {"trees:"..name.."_leaf"},
	})

	-- Plank
	minetest.register_node(items.plank, {
		tree_type = name,
		description = def.basename.." Plank",
		tiles = {def.plank},
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 1, plank = 1},
	})

	-- [recipe] Plank
	minetest.register_craft({
		type = "shapeless",
		output = items.plank.." 4",
		recipe = {"trees:"..name.."_large"},
	})

	-- Leaf
	minetest.register_node(items.leaf, {
		tree_type = name,
		description = def.basename.." Leaf",
		tiles = {def.leaf},
		drawtype = "allfaces_optional",
		waving = 1,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = {snappy = 3, flammable = 2, leaves = 1},
	})

	-- Wall Node
	minetest.register_node(items.wall, {
		tree_type = name,
		description = def.basename.." Wall",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/4, -1/2, -1/4, 1/4, 1/2, 1/4}},
			connect_front = {{-3/16, -1/2, -1/2,  3/16, 3/8, -1/4}},
			connect_left = {{-1/2, -1/2, -3/16, -1/4, 3/8,  3/16}},
			connect_back = {{-3/16, -1/2,  1/4,  3/16, 3/8,  1/2}},
			connect_right = {{ 1/4, -1/2, -3/16,  1/2, 3/8,  3/16}},
		},
		collision_box = {
			type = "fixed",
			fixed = {{-1/4, -1/2, -1/4, 1/4, 0.9, 1/4}},
		},
		connects_to = {"group:wall", "group:plank", "group:log"},
		paramtype = "light",
		is_ground_content = false,
		tiles = {def.sides},
		walkable = true,
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wall = 1}
	})

	-- [recipe] Wall
	minetest.register_craft({
		output = items.wall.." 6",
		recipe = {
			{items.plank, items.plank, items.plank},
			{items.plank, items.plank, items.plank},
		},
	})

	-- Fence
	minetest.register_node(items.fence, {
		tree_type = name,
		description = def.basename.." Fence",
		inventory_image = "trees_fence_overlay.png^"..def.plank..
				"^trees_fence_overlay.png^[makealpha:255,126,126",
		inventory_image = "trees_fence_overlay.png^"..def.plank..
				"^trees_fence_overlay.png^[makealpha:255,126,126",
		tiles = {def.plank},
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {{-1/8, -1/2, -1/8, 1/8, 1/2, 1/8}},
			connect_front = {{-1/16,3/16,-1/2,1/16,5/16,-1/8},
				{-1/16,-5/16,-1/2,1/16,-3/16,-1/8}},
			connect_left = {{-1/2,3/16,-1/16,-1/8,5/16,1/16},
				{-1/2,-5/16,-1/16,-1/8,-3/16,1/16}},
			connect_back = {{-1/16,3/16,1/8,1/16,5/16,1/2},
				{-1/16,-5/16,1/8,1/16,-3/16,1/2}},
			connect_right = {{1/8,3/16,-1/16,1/2,5/16,1/16},
				{1/8,-5/16,-1/16,1/2,-3/16,1/16}},
		},
		collision_box = {
			type = "fixed",
			fixed = {{-1/4, -1/2, -1/4, 1/4, 0.9, 1/4}},
		},
		connects_to = {"group:fence", "group:plank", "group:log"},
		sunlight_propagates = true,
		is_ground_content = false,
		paramtype = "light",
		groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, fence = 1},
	})

	-- [recipe] Fence
	minetest.register_craft({
		output = items.fence.." 4",
		recipe = {
			{items.plank, "trees:stick", items.plank},
			{items.plank, "trees:stick", items.plank},
		},
	})

	-- Decoration
	if def.mapgen and def.schematic then
		local mapgen = def.mapgen
		mapgen.deco_type = "schematic"
		mapgen.sidelen = mapgen.sidelen or 16
		mapgen.flags = "place_center_x, place_center_z"
		mapgen.rotation = "random"
		mapgen.schematic = path.."/"..def.schematic
		minetest.register_decoration(mapgen)
	end

	-- General
	def.name = name
	def.min_light = def.min_light or 13
	def.time = def.time or {
		start_min = 2400,
		start_max = 4800,
		retry_min = 240,
		retry_max = 600,
	}

	-- Add to table
	trees.registered[name] = def
end

-- [function] Get name
function trees.get_name(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		local def = minetest.registered_nodes[node.name]
		if def.tree_type and trees.registered[def.tree_type] then
			return def.tree_type
		end
	end
end

-- [function] Get definition
function trees.get_def(pos)
	local node = minetest.get_node_or_nil(pos)
	if node then
		local def = minetest.registered_nodes[node.name]
		if def.tree_type and trees.registered[def.tree_type] then
			return trees.registered[def.tree_type]
		end
	end
end

-- [function] Can grow
function trees.can_grow(pos)
	local def = trees.get_def(pos)
	if not def then return end

	local light = def.min_light

	local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	-- Check for node under
	if not node_under then
		return
	end

	local name_under = node_under.name
	-- Check if soil group
	if minetest.get_item_group(name_under, "soil") == 0 then
		return
	end

	local light_level = minetest.get_node_light(pos)
	if light and not light_level or light_level < light then
		return
	end

	return true
end

-- [function] Place tree
function trees.place(name, pos)
	if trees.registered[name] then
		local tree = trees.registered[name]
		if tree.schematic then
			if tree.offset then
				pos = vector.add(tree.offset, pos)
			end

			return minetest.place_schematic(pos, path.."/"..tree.schematic, "random",
					nil, false)
		end
	end
end

-- [function] Grow tree
function trees.grow(pos)
	if trees.can_grow(pos) then
		local name     = trees.get_name(pos)
		local basename = trees.get_def(pos).basename
		-- Log message
		minetest.log("action", "A "..basename.." sapling grows into a tree at "..
				minetest.pos_to_string(pos))
		-- Place tree
		trees.place(name, pos)
	else
		local def = trees.get_def(pos)
		if def then
			minetest.get_node_timer(pos):start(math.random(def.time.retry_min, def.time.retry_max))
		end
	end
end

---
--- Chatcommands
---

-- [register chatcommand] Place tree
minetest.register_chatcommand("place_tree", {
	description = "[DEBUG] Place tree",
	params = "<tree name> <pos (x y z)>",
	privs = {debug=true},
	func = function(name, param)
		local tname, p = string.match(param, "^([^ ]+) *(.*)$")
		local pos     = minetest.string_to_pos(p)

		if not pos then
			pos = minetest.get_player_by_name(name):getpos()
		end

		return true, "Success: "..dump(trees.place(tname, pos))
	end
})

---
--- Load Trees
---

dofile(minetest.get_modpath("trees").."/trees.lua")
