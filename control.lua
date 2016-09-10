require "util"

local debug_mode = false
local set = false

copy_paste_multiplier = copy_paste_multiplier or {}
copy_paste_multiplier.config = copy_paste_multiplier.config or {}
require "config"

--===================================================================--
--########################## EVENT HANDLERS #########################--
--===================================================================--

script.on_event(defines.events.on_tick, function(event)
  if not set then
    for i, player in pairs(game.players) do
      if PlayerOk(player) then
        local tech = player.force.technologies["logistic-system"]
        if tech and tech.valid and tech.researched then
          HideGUI(player)
          ShowGUI(player)
        end
      end
    end
    set = true
  end
end)

script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game, defines.events.on_player_respawned}, function(event)
  if event.player_index then
    local player = game.players[event.player_index]
    if PlayerOk(player) then
      local tech = player.force.technologies["logistic-system"]
      if tech and tech.valid and tech.researched then
        ShowGUI(player)
      end
    end
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  if event.research and event.research.valid and event.research.name == "logistic-system" then
    for i, player in pairs(event.research.force.players) do
      if PlayerOk(player) then
        ShowGUI(player)
      end
    end
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element and event.element.name == "copy_paste_multiplier_textfield_multiplier" then
    event.element.text = RemoveNonDigitalSymbols(event.element.text)
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event) 
  if EntityOk(event.source) and EntityOk(event.destination) and event.destination.type == "logistic-container" then
    dbg("Source type = " .. event.source.type)
    dbg("Destin type = " .. event.destination.type)
    local player = GetCopypastingPlayer(event.source, event.destination)
    local multiplier = GetMultiplier(player)
    if copy_paste_multiplier.config.multiply_source then
      local items_to_request = GetItemsToRequest(event.source)
      SetItemsToRequest(event.destination, items_to_request, multiplier)
    else
      MultiplyRequestedItems(event.destination, multiplier)
    end
  end
end)

--===================================================================--
--############################ FUNCTIONS ############################--
--===================================================================--

function PlayerOk(player)
  return (player and player.connected and player.valid)
end

function EntityOk(entity)
  return (entity and entity.valid)
end

function GetCopypastingPlayer(source_entity, destination_entity)
  for i, player in pairs(game.players) do
    if PlayerOk(player) and player.surface.name == destination_entity.surface.name and player.selected and player.selected.valid and GetEntityKey(player.selected) == GetEntityKey(destination_entity) and GetEntityKey(source_entity) == GetEntityKey(player.entity_copy_source) then
      return player
    end
  end
end

function GetEntityKey(entity)
  return entity.name .. entity.position.x .. entity.position.y .. entity.surface.name
end

function GetItemsToRequest(entity)
  local items_to_request = {}
  if entity.type == "assembling-machine" and entity.recipe then
    items_to_request = GetRequestableIngredients(entity.recipe)
  elseif entity.type == "logistic-container" then
    items_to_request = GetRequestedItems(entity)
  end
  return items_to_request
end

function GetRequestableIngredients(recipe)
  local items = {}
  dbg(recipe.localised_name)
  for i, ingredient in pairs(recipe.ingredients) do
    dbg("[" .. ingredient.type .. "] " .. ingredient.name .. " = " .. ingredient.amount)
    if ingredient.type == "item" then
      table.insert(items, {name = ingredient.name, count = ingredient.amount})
    end
  end
  return items
end

function GetRequestedItems(logistic_container_entity)
  local slots_num = logistic_container_entity.request_slot_count
  local items = {}
  if slots_num and slots_num > 0 then
    for slot_index = 1, slots_num, 1 do
      local item = logistic_container_entity.get_request_slot(slot_index)
      table.insert(items, item)
    end
  end
  return items
end

function SetItemsToRequest(logistic_container_entity, items_to_request, multiplier)
  ClearCurrentRequest(logistic_container_entity)
  local slots_num = logistic_container_entity.request_slot_count
  if slots_num and slots_num > 0 then
    for slot_index = 1, slots_num, 1 do
      if items_to_request[slot_index] then
        local request = items_to_request[slot_index]
        request.count = request.count * multiplier
        logistic_container_entity.set_request_slot(request, slot_index)
        
      else
        return
      end
    end
  end
end

function MultiplyRequestedItems(destination_entity, multiplier)
  local request_slots_num = destination_entity.request_slot_count
  if request_slots_num and request_slots_num > 0 then
    for slot_index = 1, request_slots_num, 1 do
      requested_stack = destination_entity.get_request_slot(slot_index)
      if requested_stack then
        local new_stack = {name = requested_stack.name, count = requested_stack.count * multiplier}
        destination_entity.set_request_slot(new_stack, slot_index)
      end
    end
  end
  return false
end

function ClearCurrentRequest(logistic_container_entity)
  local slots_num = logistic_container_entity.request_slot_count
  if slots_num and slots_num > 0 then
    for slot_index = 1, slots_num, 1 do
      logistic_container_entity.clear_request_slot(slot_index)
    end
  end
end

function RemoveNonDigitalSymbols(text)
  local result = 0
  local str_len = string.len(text)
  if str_len == 0 then
    return ""
  end
  for i = 1, str_len, 1 do
    local current_symbol = tonumber(string.sub(text, i, i))
    local current_symbol_as_digit = tonumber(current_symbol)
    if current_symbol_as_digit then
      result = result * 10 + current_symbol_as_digit
    end
  end
  result = math.floor(result)
  if not (result > 0) then
    result = 1
  end
  return result
end

function dbg(msg)
  if debug_mode then
    game.players[1].print(msg)
  end
end

--===================================================================--
--############################### GUI ###############################--
--===================================================================--

--Shows mod's GUI.
function ShowGUI(player)
  if PlayerOk(player) then
    local gui = player.gui.top
    if not gui["copy_paste_multiplier_main_frame"] then
      local main_frame = gui.add({type="frame", name="copy_paste_multiplier_main_frame", direction = "horizontal", style = "copy_paste_multiplier_thin_frame"})
      main_frame.add({type="button", name="copy_paste_multiplier_header", style = "copy_paste_multiplier_sprite_button_style"})
      main_frame.add({type="label", name="copy_paste_multiplier_label", caption = "×"})
      local textfield = main_frame.add({type="textfield", name="copy_paste_multiplier_textfield_multiplier", text = "1", style = "copy_paste_multiplier_textfield"})
      textfield.tooltip = {"cpm-tooltip-multiplier"}
    end
  end
end

--Hides mod's GUI.
function HideGUI(player)
  if PlayerOk(player) then
    local gui = player.gui.top
    if gui["copy_paste_multiplier_main_frame"] then
      gui["copy_paste_multiplier_main_frame"].destroy()
    end
  end
end

function GetMultiplier(player)
	local default_multiplier = 1
  if PlayerOk(player) then
    if player.gui.top["copy_paste_multiplier_main_frame"] and player.gui.top["copy_paste_multiplier_main_frame"]["copy_paste_multiplier_textfield_multiplier"] then
      local textfield = player.gui.top["copy_paste_multiplier_main_frame"]["copy_paste_multiplier_textfield_multiplier"]
      local multiplier = tonumber(textfield.text)
      if multiplier and multiplier >= 1 then
        if math.floor(multiplier) ~= multiplier then --multiplier is not integer
          multiplier = math.floor(multiplier)
          textfield.text = tostring(multiplier)
        end
        dbg("multiplier = " .. multiplier)
        return multiplier
      else --multiplier is nil or <1
        textfield.text = tostring(default_multiplier)
      end
    end
  end
  return default_multiplier --default
end
