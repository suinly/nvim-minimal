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
local cwd, oldfiles = vim.fn.getcwd(), vim.v.oldfiles
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p")
directory = vim.uv.fs_realpath(directory)
local paths = {
  directory .. "/" .. string.rep("long-name-", 8) .. ".txt",
  directory .. "/" .. string.rep("界", 35) .. ".txt",
  directory .. "/short.txt",
}
for _, path in ipairs(paths) do vim.fn.writefile({ "test" }, path) end
vim.cmd.cd(vim.fn.fnameescape(directory))
vim.v.oldfiles = paths
MiniStarter.open()
local recent = {}
for _, row in ipairs(MiniStarter.get_content()) do
  for _, unit in ipairs(row) do
    if unit.type == "item" and unit.item.section == "Recent files (current directory)" then
      assert(vim.fn.strdisplaywidth(unit.string) <= 60, "Recent file labels must not widen Starter")
      recent[#recent + 1] = unit.item
    end
  end
end
assert(#recent == 3)
for index = 1, 2 do
  assert(recent[index].name:sub(-#"…") == "…", "Long labels must end with an ellipsis")
  recent[index].action()
  assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) == vim.uv.fs_realpath(paths[index]), "Truncated labels must open the full file path")
end
assert(recent[3].name == "short.txt (short.txt)", "Short labels must remain unchanged")
vim.cmd.cd(vim.fn.fnameescape(cwd))
vim.v.oldfiles = oldfiles
vim.fn.delete(directory, "rf")
print("Starter animation and filename checks passed")
