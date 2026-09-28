-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/starter.lua")' '+qa!'
MiniStarter.open()
local session = vim.fn.tempname() .. ".vim"
vim.cmd.mksession({ session, bang = true })
local result = vim.system({
  vim.v.progpath, "--headless", "-i", "NONE", "-u", "init.lua", "-S", session,
  "+lua local ok, err = pcall(function() assert(vim.bo.filetype == 'ministarter'); local row = vim.api.nvim_win_get_cursor(0)[1]; vim.fn.maparg('j', 'n', false, true).callback(); assert(vim.api.nvim_win_get_cursor(0)[1] > row); vim.fn.maparg('k', 'n', false, true).callback(); assert(vim.api.nvim_win_get_cursor(0)[1] == row) end); if not ok then print(err); vim.cmd('cquit') end",
  "+qa!",
}, { text = true }):wait()
vim.fn.delete(session)
assert(result.code == 0, "Restored Starter navigation must work: " .. (result.stderr or ""))
local file = vim.fn.tempname() .. ".txt"
vim.fn.writefile({ "first", "second", "third" }, file)
vim.cmd.edit(vim.fn.fnameescape(file))
vim.cmd.mksession({ session, bang = true })
result = vim.system({
  vim.v.progpath, "--headless", "-i", "NONE", "-u", "init.lua",
  "+lua local ok, err = pcall(function() vim.api.nvim_exec_autocmds('VimEnter', {}); vim.cmd.source(" .. vim.inspect(session) .. "); vim.wait(100); assert(vim.fn.maparg('j', 'n', false, true).buffer ~= 1); assert(vim.fn.maparg('k', 'n', false, true).buffer ~= 1); vim.api.nvim_win_set_cursor(0, {1, 0}); vim.api.nvim_feedkeys('j', 'xt', false); assert(vim.api.nvim_win_get_cursor(0)[1] == 2); vim.api.nvim_feedkeys('k', 'xt', false); assert(vim.api.nvim_win_get_cursor(0)[1] == 1) end); if not ok then print(err); vim.cmd('cquit') end",
  "+qa!",
}, { text = true }):wait()
vim.fn.delete(session)
vim.fn.delete(file)
assert(result.code == 0, "Restored file navigation must work: " .. (result.stderr or ""))
MiniStarter.open()
local buf = vim.api.nvim_get_current_buf()
local backend = require("herdr-splits.herdr")
local in_session, zoomed, resize_pane = backend.is_in_session, backend.current_pane_is_zoomed, backend.resize_pane
backend.is_in_session = function() return true end
backend.current_pane_is_zoomed = function() return false end
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  local called = false
  backend.resize_pane = function(actual, amount)
    assert(actual == direction and amount > 0)
    called = true
    return true
  end
  vim.fn.maparg("<C-M-" .. key .. ">", "n", false, true).callback()
  assert(called, "Starter resize must reach Herdr: " .. direction)
end
backend.is_in_session, backend.current_pane_is_zoomed, backend.resize_pane = in_session, zoomed, resize_pane
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
