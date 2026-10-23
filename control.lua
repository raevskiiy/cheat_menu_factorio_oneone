local mod_gui = require("mod-gui")

local OPEN_BUTTON = "cm_open_button"
local FRAME = "cm_frame"
local CLOSE_BUTTON = "cm_close"
local SLIDER_PREFIX = "cm_slider_"
local VALUE_PREFIX = "cm_value_"
local TOGGLE_PREFIX = "cm_toggle_"
local ACTION_PREFIX = "cm_action_"
local ICON = "item/exoskeleton-equipment"

-- kind: "mult" -> shown as total multiplier (1 + bonus), "plus" -> shown as +bonus
local SLIDERS = {
  { key = "crafting",  min = 0, max = 100,   step = 1,   kind = "mult",
    props = { "character_crafting_speed_modifier" } },
  { key = "running",   min = 0, max = 10,    step = 0.5, kind = "mult",
    props = { "character_running_speed_modifier" } },
  { key = "mining",    min = 0, max = 100,   step = 1,   kind = "mult",
    props = { "character_mining_speed_modifier" } },
  -- the engine caps distance bonuses at 320
  { key = "reach",     min = 0, max = 320,   step = 5,   kind = "plus",
    props = {
      "character_build_distance_bonus",
      "character_reach_distance_bonus",
      "character_resource_reach_distance_bonus",
      "character_item_drop_distance_bonus",
      "character_item_pickup_distance_bonus",
      "character_loot_pickup_distance_bonus",
    } },
  { key = "health",    min = 0, max = 10000, step = 100, kind = "plus",
    props = { "character_health_bonus" } },
  { key = "inventory", min = 0, max = 200,   step = 10,  kind = "plus",
    props = { "character_inventory_slots_bonus" } },
}

local SLIDER_BY_KEY = {}
for _, s in pairs(SLIDERS) do SLIDER_BY_KEY[s.key] = s end

local TOGGLES = { "god", "cheat_mode", "always_day" }
local ACTIONS = { "heal", "research", "recipes", "chart", "pollution", "reset" }

---------------------------------------------------------------------------
-- helpers
---------------------------------------------------------------------------

local function strip_prefix(name, prefix)
  if name and name:sub(1, #prefix) == prefix then
    return name:sub(#prefix + 1)
  end
  return nil
end

local function get_data(player_index)
  storage.players = storage.players or {}
  local d = storage.players[player_index]
  if not d then
    d = { god = false, god_applied = false }
    storage.players[player_index] = d
  end
  for _, s in pairs(SLIDERS) do
    if d[s.key] == nil then d[s.key] = 0 end
    -- clamp values saved by older versions of the mod
    d[s.key] = math.max(s.min, math.min(s.max, d[s.key]))
  end
  return d
end

local function can_use(player)
  if not (player and player.valid) then return false end
  if settings.global["cheat-menu-admin-only"].value then
    return player.admin
  end
  return true
end

local function format_value(s, v)
  if s.kind == "mult" then
    return "x" .. string.format("%g", 1 + v)
  end
  return "+" .. string.format("%g", v)
end

--- Apply stored modifiers to the player's current character.
local function apply(player)
  if not (player and player.valid) then return end
  local char = player.character
  if not (char and char.valid) then return end
  local data = get_data(player.index)

  for _, s in pairs(SLIDERS) do
    for _, prop in pairs(s.props) do
      -- pcall: the engine rejects out-of-range values with an error
      pcall(function() player[prop] = data[s.key] end)
    end
  end

  if data.god then
    char.destructible = false
    data.god_applied = true
  elseif data.god_applied then
    char.destructible = true
    data.god_applied = false
  end
end

---------------------------------------------------------------------------
-- top-left button (lives in mod_gui button flow, so GUI Unifier can style it)
---------------------------------------------------------------------------

local function apply_button_style(player, button)
  local candidates = {}
  if script.active_mods["GUI_Unifyer"] then
    local ok, gu_style = pcall(function()
      return settings.get_player_settings(player)["gu_button_style_setting"].value
    end)
    if ok and gu_style then
      if player.gui.screen[FRAME] then
        candidates[#candidates + 1] = gu_style .. "_selected"
      end
      candidates[#candidates + 1] = gu_style
    end
  end
  candidates[#candidates + 1] = mod_gui.button_style

  for _, style_name in ipairs(candidates) do
    if pcall(function() button.style = style_name end) then
      return
    end
  end
end

local function refresh_button(player)
  if not (player and player.valid) then return end
  local flow = mod_gui.get_button_flow(player)
  local button = flow[OPEN_BUTTON]
  if can_use(player) then
    if not button then
      button = flow.add {
        type = "sprite-button",
        name = OPEN_BUTTON,
        sprite = ICON,
        tooltip = { "cheat-menu.button-tooltip" },
      }
    end
    apply_button_style(player, button)
  elseif button then
    button.destroy()
  end
end

---------------------------------------------------------------------------
-- window
---------------------------------------------------------------------------

local function close_window(player)
  local frame = player.gui.screen[FRAME]
  if frame then frame.destroy() end
  refresh_button(player)
end

local function add_section_label(parent, key)
  local label = parent.add {
    type = "label",
    caption = { "cheat-menu." .. key },
    style = "caption_label",
  }
  label.style.top_margin = 4
  return label
end

local function build_window(player)
  local screen = player.gui.screen
  if screen[FRAME] then screen[FRAME].destroy() end
  local data = get_data(player.index)

  local frame = screen.add { type = "frame", name = FRAME, direction = "vertical" }
  frame.auto_center = true

  -- title bar
  local titlebar = frame.add { type = "flow", direction = "horizontal" }
  titlebar.drag_target = frame
  titlebar.add {
    type = "label",
    caption = { "cheat-menu.title" },
    style = "frame_title",
    ignored_by_interaction = true,
  }
  local filler = titlebar.add {
    type = "empty-widget",
    style = "draggable_space_header",
    ignored_by_interaction = true,
  }
  filler.style.horizontally_stretchable = true
  filler.style.height = 24
  titlebar.add {
    type = "sprite-button",
    name = CLOSE_BUTTON,
    style = "frame_action_button",
    sprite = "utility/close", -- 2.x: "close_white" was removed, "close" is the white icon
    hovered_sprite = "utility/close_black",
    clicked_sprite = "utility/close_black",
    tooltip = { "cheat-menu.close" },
  }

  local inner = frame.add {
    type = "frame",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  -- sliders
  add_section_label(inner, "section-modifiers")
  for _, s in pairs(SLIDERS) do
    local row = inner.add { type = "flow", direction = "horizontal" }
    row.style.vertical_align = "center"
    local label = row.add {
      type = "label",
      caption = { "cheat-menu.slider-" .. s.key },
      tooltip = { "cheat-menu.slider-" .. s.key .. "-tooltip" },
    }
    label.style.width = 170
    local slider = row.add {
      type = "slider",
      name = SLIDER_PREFIX .. s.key,
      minimum_value = s.min,
      maximum_value = s.max,
      value = data[s.key],
      value_step = s.step,
    }
    slider.style.width = 200
    local value_label = row.add {
      type = "label",
      name = VALUE_PREFIX .. s.key,
      caption = format_value(s, data[s.key]),
    }
    value_label.style.width = 80
  end

  -- toggles
  add_section_label(inner, "section-toggles")
  local toggle_state = {
    god = data.god,
    cheat_mode = player.cheat_mode,
    always_day = player.surface.always_day,
  }
  for _, key in ipairs(TOGGLES) do
    inner.add {
      type = "checkbox",
      name = TOGGLE_PREFIX .. key,
      caption = { "cheat-menu.toggle-" .. key },
      tooltip = { "cheat-menu.toggle-" .. key .. "-tooltip" },
      state = toggle_state[key] and true or false,
    }
  end

  -- actions
  add_section_label(inner, "section-actions")
  local tbl = inner.add { type = "table", column_count = 2 }
  for _, key in ipairs(ACTIONS) do
    local b = tbl.add {
      type = "button",
      name = ACTION_PREFIX .. key,
      caption = { "cheat-menu.action-" .. key },
      tooltip = { "cheat-menu.action-" .. key .. "-tooltip" },
    }
    b.style.horizontally_stretchable = true
  end

  player.opened = frame
  refresh_button(player)
end

local function toggle_window(player)
  if player.gui.screen[FRAME] then
    close_window(player)
  else
    build_window(player)
  end
end

---------------------------------------------------------------------------
-- actions
---------------------------------------------------------------------------

local action_handlers = {}

function action_handlers.heal(player, data)
  local char = player.character
  if char and char.valid then
    -- 2.x: LuaEntity.max_health already accounts for the character health bonus and quality
    local ok = pcall(function() char.health = char.max_health end)
    if not ok then
      -- fallback: the engine clamps health to the maximum
      pcall(function() char.health = 1000000 end)
    end
    player.print({ "cheat-menu.msg-healed" })
  end
end

function action_handlers.research(player, data)
  player.force.research_all_technologies()
  player.print({ "cheat-menu.msg-researched" })
end

function action_handlers.recipes(player, data)
  player.force.enable_all_recipes()
  player.print({ "cheat-menu.msg-recipes" })
end

function action_handlers.chart(player, data)
  local p = player.position
  local r = 500
  player.force.chart(player.surface, { { p.x - r, p.y - r }, { p.x + r, p.y + r } })
  player.print({ "cheat-menu.msg-charted", r })
end

function action_handlers.pollution(player, data)
  player.surface.clear_pollution()
  player.print({ "cheat-menu.msg-pollution" })
end

function action_handlers.reset(player, data)
  for _, s in pairs(SLIDERS) do data[s.key] = 0 end
  data.god = false
  apply(player)
  build_window(player)
  player.print({ "cheat-menu.msg-reset" })
end

---------------------------------------------------------------------------
-- player setup
---------------------------------------------------------------------------

local function setup_player(player)
  if not (player and player.valid) then return end
  get_data(player.index)
  refresh_button(player)
  apply(player)
end

local function setup_all_players()
  for _, player in pairs(game.players) do
    setup_player(player)
  end
end

---------------------------------------------------------------------------
-- events
---------------------------------------------------------------------------

script.on_init(function()
  storage.players = {}
  setup_all_players()
end)

script.on_configuration_changed(function()
  storage.players = storage.players or {}
  for _, player in pairs(game.players) do
    local frame = player.gui.screen[FRAME]
    if frame then frame.destroy() end
    setup_player(player)
  end
end)

script.on_event({
  defines.events.on_player_created,
  defines.events.on_player_joined_game,
  defines.events.on_player_respawned,
  defines.events.on_player_controller_changed,
  defines.events.on_player_promoted,
  defines.events.on_player_demoted,
}, function(event)
  local player = game.get_player(event.player_index)
  setup_player(player)
  if player and player.valid and not can_use(player) then
    local frame = player.gui.screen[FRAME]
    if frame then frame.destroy() end
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  if storage.players then storage.players[event.player_index] = nil end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == "cheat-menu-admin-only" then
    for _, player in pairs(game.players) do
      refresh_button(player)
      if not can_use(player) then
        local frame = player.gui.screen[FRAME]
        if frame then frame.destroy() end
      end
    end
  elseif event.setting == "gu_button_style_setting" then
    -- GUI Unifier style changed: re-style our button
    if event.player_index then
      refresh_button(game.get_player(event.player_index))
    else
      for _, player in pairs(game.players) do refresh_button(player) end
    end
  end
end)

script.on_event("cheat-menu-toggle", function(event)
  local player = game.get_player(event.player_index)
  if player and can_use(player) then toggle_window(player) end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player = game.get_player(event.player_index)
  if not can_use(player) then return end

  if element.name == OPEN_BUTTON then
    toggle_window(player)
  elseif element.name == CLOSE_BUTTON then
    close_window(player)
  else
    local key = strip_prefix(element.name, ACTION_PREFIX)
    if key and action_handlers[key] then
      action_handlers[key](player, get_data(player.index))
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local element = event.element
  if element and element.valid and element.name == FRAME then
    close_window(game.get_player(event.player_index))
  end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local key = strip_prefix(element.name, SLIDER_PREFIX)
  local s = key and SLIDER_BY_KEY[key]
  if not s then return end

  local player = game.get_player(event.player_index)
  if not can_use(player) then return end

  -- snap to the step ourselves so we do not depend on slider flags that differ between versions
  local value = math.floor(element.slider_value / s.step + 0.5) * s.step
  value = math.max(s.min, math.min(s.max, value))
  if value ~= element.slider_value then element.slider_value = value end

  local data = get_data(player.index)
  data[key] = value
  local value_label = element.parent[VALUE_PREFIX .. key]
  if value_label then value_label.caption = format_value(s, data[key]) end
  apply(player)
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local key = strip_prefix(element.name, TOGGLE_PREFIX)
  if not key then return end

  local player = game.get_player(event.player_index)
  if not can_use(player) then return end

  local data = get_data(player.index)
  if key == "god" then
    data.god = element.state
    apply(player)
  elseif key == "cheat_mode" then
    player.cheat_mode = element.state
  elseif key == "always_day" then
    player.surface.always_day = element.state
  end
end)
