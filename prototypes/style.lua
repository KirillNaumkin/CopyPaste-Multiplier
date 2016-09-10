MOD_NAME = "__CopyPaste Multiplier__"

data.raw["gui-style"].default["copy_paste_multiplier_thin_frame"] = {
  type = "frame_style",
  parent="frame_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["copy_paste_multiplier_thin_flow"] = {
  type = "flow_style",
  parent="flow_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["copy_paste_multiplier_thin_label"] = {
  type = "label_style",
  top_padding  = 0,
  bottom_padding = 0,
  left_padding = 0,
  right_padding = 0,
}
data.raw["gui-style"].default["copy_paste_multiplier_button_style"] = {
  type = "button_style",
  parent = "button_style",
  font = "cpm_big_font",
  width = 32,
  height = 32,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  left_click_sound =
  {
    {
      filename = "__core__/sound/gui-click.ogg",
      volume = 1
    }
  }
}
data.raw["gui-style"].default["copy_paste_multiplier_textfield"] = {
  type = "textfield_style",
  parent = "textfield_style",
  minimal_width = 32,
  maximal_width = 32,
  font = "cpm_small_font",
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}

local gs = 
{
  type = "monolith",
  monolith_image =
  {
    filename = MOD_NAME .. "/graphics/copy-paste.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    x = 0,
    y = 0,
  }
}

data.raw["gui-style"].default["copy_paste_multiplier_sprite_button_style"] = {
  type = "button_style",
  parent = "button_style",
  width = 26,
  height = 26,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  font = "default-button",
  default_graphical_set = gs,
  hovered_graphical_set = gs,
  clicked_graphical_set = gs
}

data:extend({
  {
    type = "font",
    name = "cpm_small_font",
    from = "default",
    size = 14
  },
  {
    type = "font",
    name = "cpm_big_font",
    from = "default",
    size = 18
  },
})