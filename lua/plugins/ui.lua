-- Catppuccin Theme
vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }

require("catppuccin").setup({
  flavour = "macchiato",
  custom_highlights = function(colors)
    return {
      MiniJump = { fg = colors.base, bg = colors.yellow },
      MiniStarterHeader = { fg = colors.lavender, style = { "bold" } },
      StarterLogo = { fg = colors.lavender, style = { "bold" } },
      MiniStarterSection = { fg = colors.lavender, style = { "bold" } },
      MiniStarterItem = { fg = colors.text },
      MiniStarterItemBullet = { fg = colors.overlay1 },
      MiniStarterItemPrefix = { fg = colors.lavender },
      MiniStarterFooter = { fg = colors.overlay1, style = {} },
      MiniStarterQuery = { fg = colors.base, bg = colors.lavender },
      MiniStatuslineModeNormal = { fg = colors.base, bg = colors.lavender, style = { "bold" } },
      MiniStatuslineModeInsert = { fg = colors.base, bg = colors.green, style = { "bold" } },
      MiniStatuslineModeVisual = { fg = colors.base, bg = colors.mauve, style = { "bold" } },
      MiniStatuslineModeReplace = { fg = colors.base, bg = colors.red, style = { "bold" } },
      MiniStatuslineModeCommand = { fg = colors.base, bg = colors.peach, style = { "bold" } },
      MiniStatuslineModeOther = { fg = colors.base, bg = colors.teal, style = { "bold" } },
      MiniStatuslineDevinfo = { fg = colors.subtext1, bg = colors.surface0 },
      MiniStatuslineFilename = { fg = colors.text, bg = colors.mantle },
      MiniStatuslineFileinfo = { fg = colors.subtext0, bg = colors.surface0 },
      MiniStatuslineInactive = { fg = colors.overlay1, bg = colors.mantle },
      MiniTablineCurrent = { fg = colors.base, bg = colors.lavender, style = { "bold" } },
      MiniTablineModifiedCurrent = { fg = colors.base, bg = colors.lavender, style = { "bold" } },
      MiniTablineVisible = { fg = colors.text, bg = colors.surface0 },
      MiniTablineModifiedVisible = { fg = colors.peach, bg = colors.surface0 },
      MiniTablineHidden = { fg = colors.subtext0, bg = colors.mantle },
      MiniTablineModifiedHidden = { fg = colors.peach, bg = colors.mantle },
      MiniTablineFill = { bg = colors.mantle },
      MiniTablineTabpagesection = { fg = colors.lavender, bg = colors.surface0, bold = true },
      MiniTablineTrunc = { fg = colors.overlay1, bg = colors.mantle },
    }
  end,
})

-- Icons
vim.pack.add({ "https://github.com/nvim-mini/mini.icons" })
require("mini.icons").setup()

-- Starter
vim.pack.add({ "https://github.com/nvim-mini/mini.starter" })
local starter = require("mini.starter")
local logo = [[
█▀▀▄ █▀▀█ █▀▀▄ ▀█▀ █▀▀ █    █▀▀ █   █▀▀█ █   █
█  █ █▄▄█ █  █  █  █▀▀ █    █▀▀ █   █  █ █▄█▄█
▀▀▀  ▀  ▀ ▀  ▀ ▀▀▀ ▀▀▀ ▀▀▀  ▀   ▀▀▀ ▀▀▀▀  ▀ ▀]]
starter.setup({
  header = function()
    return logo .. "\n\n" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
  end,
  items = {
    { name = "Find file", action = "Pick files", section = "Actions" },
    { name = "Search text", action = "Pick grep_live", section = "Actions" },
    { name = "Explorer", action = function() MiniFiles.open() end, section = "Actions" },
    { name = "New file", action = "enew", section = "Actions" },
    { name = "Git", action = function()
      vim.fn.maparg("<leader>gg", "n", false, true).callback()
    end, section = "Actions" },
    starter.sections.recent_files(5, true),
  },
  content_hooks = {
    function(content)
      for row = 1, 3 do content[row][1].hl = "StarterLogo" end
      return content
    end,
    starter.gen_hook.adding_bullet("· "),
    starter.gen_hook.aligning("center", "center"),
  },
  footer = "j/k to navigate  ·  Type to filter  ·  Enter to open  ·  Esc to reset",
})

local logo_timer
local function stop_logo_animation()
  if logo_timer then
    logo_timer:stop()
    logo_timer:close()
    logo_timer = nil
  end
end
local function animate_logo()
  if vim.bo.filetype ~= "ministarter" or logo_timer then return end
  local palette = require("catppuccin.palettes").get_palette("macchiato")
  local colors = { palette.lavender, palette.blue, palette.pink }
  local frame = 0
  local timer = vim.uv.new_timer()
  logo_timer = timer
  timer:start(0, 50, vim.schedule_wrap(function()
    if logo_timer ~= timer then return end
    local index = math.floor(frame / 60) % #colors + 1
    local from, to = colors[index], colors[index % #colors + 1]
    local progress = (1 - math.cos(math.pi * (frame % 60) / 60)) / 2
    local rgb = {}
    for channel = 1, 3 do
      local offset = 2 * channel
      local a = tonumber(from:sub(offset, offset + 1), 16)
      local b = tonumber(to:sub(offset, offset + 1), 16)
      rgb[channel] = math.floor(a + (b - a) * progress + 0.5)
    end
    vim.api.nvim_set_hl(0, "StarterLogo", { fg = string.format("#%02x%02x%02x", unpack(rgb)), bold = true })
    frame = (frame + 1) % 180
    vim.cmd.redraw()
  end))
end
local animation_group = vim.api.nvim_create_augroup("StarterLogoAnimation", { clear = true })
vim.api.nvim_create_autocmd("User", { pattern = "MiniStarterOpened", group = animation_group, callback = animate_logo })
vim.api.nvim_create_autocmd("BufEnter", { group = animation_group, callback = animate_logo })
vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, { group = animation_group, callback = stop_logo_animation })

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniStarterOpened",
  group = vim.api.nvim_create_augroup("StarterNavigation", { clear = true }),
  callback = function(event)
    vim.o.showtabline = 2
    starter.refresh(event.buf)
    vim.keymap.set("n", "j", function() starter.update_current_item("next") end, { buffer = event.buf })
    vim.keymap.set("n", "k", function() starter.update_current_item("prev") end, { buffer = event.buf })
  end,
})

-- Statuscolumn
vim.pack.add({ "https://github.com/nvim-mini/mini.statuscolumn" })
require("mini.statuscolumn").setup({ dim_inactive = false })

-- Statusline
vim.pack.add({ "https://github.com/nvim-mini/mini.statusline" })
require("mini.statusline").setup()

local section_mode = MiniStatusline.section_mode
MiniStatusline.section_mode = function(args)
  local mode, highlight = section_mode(args)
  return mode:upper(), highlight
end

MiniStatusline.section_location = function()
  return "%p%% %l:%v"
end

local section_fileinfo = MiniStatusline.section_fileinfo
MiniStatusline.section_fileinfo = function()
  return section_fileinfo({ trunc_width = math.huge })
end

-- Tabline
vim.pack.add({ "https://github.com/nvim-mini/mini.tabline" })
require("mini.tabline").setup({
  tabpage_section = "right",
  format = function(buf_id, label)
    local suffix = vim.bo[buf_id].modified and "● " or ""
    return " " .. MiniTabline.default_format(buf_id, label) .. suffix .. " "
  end,
})

-- Indentscope
vim.pack.add({ "https://github.com/nvim-mini/mini.indentscope" })
require("mini.indentscope").setup({
  symbol = "│",
  draw = { animation = require("mini.indentscope").gen_animation.none() },
})

vim.cmd.colorscheme("catppuccin-nvim")
