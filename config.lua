--[[Defines what should be multiplied.
    • false: takes vanilla destination count and multiplies it. E.g. if source is some crafting machine, then vanilla destination count is [recipe cost] * 4 (for basic products) or 2 (for intermediate products), so [recipe cost] * [4 or 2] * [multiplier] will be requested; if source is requester chest then [requested count] * [multiplier] will be requested.
    • true: takes vanilla source count and multiplies it. E.g. if source is some crafting machine, then [recipe cost] * [multiplier] items will be requested by destination; if source is requester chest then [requested count] * [multiplier] will be requested.
  ]]
copy_paste_multiplier.config.multiply_source = true