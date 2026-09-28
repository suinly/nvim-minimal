-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/starter.lua")' '+qa!'
MiniStarter.open()
local buf = vim.api.nvim_get_current_buf()
local function color() return vim.api.nvim_get_hl(0, { name = "StarterLogo", link = false }).fg end
local initial = color()
assert(vim.wait(1000, function() return color() ~= initial end), "Logo color must animate")
local header = vim.api.nvim_get_hl(0, { name = "MiniStarterHeader", link = false }).fg
assert(header == tonumber(require("catppuccin.palettes").get_palette("macchiato").lavender:sub(2), 16))
local content = MiniStarter.get_content(buf)
local logo_rows = 0
for _, row in ipairs(content) do
  for _, unit in ipairs(row) do
    if unit.hl == "StarterLogo" then logo_rows = logo_rows + 1 end
  end
end
assert(logo_rows == 3, "Only logo rows should animate")
vim.cmd.enew()
local stopped = color()
assert(not vim.wait(300, function() return color() ~= stopped end), "Animation must stop outside Starter")
MiniStarter.open()
vim.wait(100)
local reopened = color()
assert(vim.wait(1000, function() return color() ~= reopened end), "Animation must restart on return")
print("Starter animation checks passed")
