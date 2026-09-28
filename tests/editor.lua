-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/editor.lua")' '+qa!'
assert(vim.o.scrolloff == 5)
assert(vim.fn.maparg("<Space>fb", "n"):find("Pick buffers", 1, true))

vim.cmd.enew()
local buf = vim.api.nvim_get_current_buf()
vim.cmd.vsplit()
local windows = vim.api.nvim_tabpage_list_wins(0)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "unsaved" })
local confirm = vim.fn.confirm
vim.fn.confirm = function() return 1 end
assert(MiniBufremove.delete(buf) == false)
assert(vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] == "unsaved")
vim.fn.confirm = confirm
vim.bo[buf].modified = false
vim.fn.maparg("<Space>bd", "n", false, true).callback()
assert(not vim.bo[buf].buflisted)
for _, win in ipairs(windows) do
  assert(vim.api.nvim_win_is_valid(win))
  assert(vim.api.nvim_win_get_buf(win) ~= buf)
end

local get_clients, format = vim.lsp.get_clients, vim.lsp.buf.format
local calls = 0
vim.lsp.get_clients = function(opts)
  assert(opts.method == "textDocument/formatting")
  return {}
end
vim.lsp.buf.format = function() error("Must skip buffers without a formatter") end
vim.api.nvim_exec_autocmds("BufWritePre", { buffer = 0 })
vim.lsp.get_clients = function() return { { id = 7 }, { id = 8 } } end
vim.lsp.buf.format = function(opts)
  assert(opts.bufnr == vim.api.nvim_get_current_buf())
  assert(opts.id == 7 and opts.async == false and opts.timeout_ms == 2000)
  calls = calls + 1
  vim.api.nvim_buf_set_lines(opts.bufnr, 0, -1, false, { "formatted" })
end
local path = vim.fn.tempname()
vim.api.nvim_buf_set_name(0, path)
vim.cmd.write()
assert(calls == 1 and vim.fn.readfile(path)[1] == "formatted")
vim.fn.delete(path)
vim.lsp.get_clients, vim.lsp.buf.format = get_clients, format
local jobstart = vim.fn.jobstart
local terminal, on_exit
local origin_win = vim.api.nvim_get_current_win()
local win_count = #vim.api.nvim_tabpage_list_wins(0)
vim.fn.jobstart = function(command, opts)
  assert(command[1] == "lazygit" and opts.term)
  assert(command[2] == "--use-config-file", "LazyGit must load the Neovim editor preset")
  assert(command[3]:find(vim.fn.stdpath("config") .. "/lazygit.yml", 1, true))
  terminal, on_exit = vim.api.nvim_get_current_buf(), opts.on_exit
  return 1
end
vim.fn.maparg("<Space>gg", "n", false, true).callback()
assert(#vim.api.nvim_tabpage_list_wins(0) == win_count + 1)
local float = vim.api.nvim_win_get_config(0)
assert(float.relative == "editor" and float.title_pos == "center")
assert(float.width == math.max(1, math.floor(vim.o.columns * 0.9)))
assert(float.height == math.max(1, math.floor((vim.o.lines - 2) * 0.85)))
assert(not vim.bo[terminal].buflisted)
local columns, lines = vim.o.columns, vim.o.lines
for _, size in ipairs({ { 60, 20 }, { 120, 40 } }) do
  vim.o.columns, vim.o.lines = size[1], size[2]
  vim.api.nvim_exec_autocmds("VimResized", {})
  local resized = vim.api.nvim_win_get_config(0)
  assert(resized.width == math.max(1, math.floor(vim.o.columns * 0.9)), "LazyGit width must follow terminal size")
  assert(resized.height == math.max(1, math.floor((vim.o.lines - 2) * 0.85)), "LazyGit height must follow terminal size")
  assert(resized.col == math.floor((vim.o.columns - resized.width - 2) / 2))
  assert(resized.row == math.floor((vim.o.lines - resized.height - 2) / 2))
end
vim.o.columns, vim.o.lines = columns, lines
vim.api.nvim_exec_autocmds("VimResized", {})
local herdr = require("herdr-splits")
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  local method = "move_cursor_" .. direction
  local original, called = herdr[method], false
  herdr[method] = function() called = true end
  local mapping = vim.fn.maparg("<C-" .. key .. ">", "t", false, true)
  assert(mapping.buffer == 1)
  mapping.callback()
  assert(called, method)
  herdr[method] = original
  local backend = require("herdr-splits.herdr")
  local resize_pane, resized = backend.resize_pane, false
  backend.resize_pane = function(actual_direction, amount)
    assert(actual_direction == direction and amount > 0)
    resized = true
  end
  local resize_mapping = vim.fn.maparg("<M-" .. key .. ">", "t", false, true)
  assert(resize_mapping.buffer == 1, "Missing LazyGit resize mapping: " .. key)
  resize_mapping.callback()
  backend.resize_pane = resize_pane
  assert(resized and vim.api.nvim_get_current_buf() == terminal)
end
for _, win in ipairs(windows) do assert(vim.api.nvim_win_is_valid(win)) end
vim.api.nvim_win_close(0, true)
assert(vim.api.nvim_buf_is_valid(terminal), "Closing the window must preserve LazyGit")
vim.fn.maparg("<Space>gg", "n", false, true).callback()
assert(vim.api.nvim_get_current_buf() == terminal, "LazyGit must reuse its terminal")
on_exit()
assert(vim.wait(1000, function() return #vim.api.nvim_tabpage_list_wins(0) == win_count end))
assert(#vim.api.nvim_tabpage_list_wins(0) == win_count)
assert(not vim.api.nvim_buf_is_valid(terminal))
assert(vim.api.nvim_get_current_win() == origin_win)
vim.fn.jobstart = jobstart
vim.cmd.stopinsert()
local active = vim.api.nvim_get_current_buf()
local other = vim.api.nvim_create_buf(true, false)
local unsaved = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(unsaved, 0, -1, false, { "keep unsaved" })
vim.fn.confirm = function() return 1 end
vim.fn.maparg("<Space>bo", "n", false, true).callback()
vim.fn.confirm = confirm
assert(vim.api.nvim_get_current_buf() == active)
assert(not vim.bo[other].buflisted)
assert(vim.bo[unsaved].buflisted and vim.bo[unsaved].modified)
assert(vim.api.nvim_buf_get_lines(unsaved, 0, -1, false)[1] == "keep unsaved")
for _, win in ipairs(windows) do assert(vim.api.nvim_win_is_valid(win)) end
local current = vim.api.nvim_get_current_buf()
local other = vim.api.nvim_create_buf(true, false)
local unsaved = vim.api.nvim_create_buf(true, false)
local unlisted = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(unsaved, 0, -1, false, { "keep changes" })
vim.fn.confirm = function() return 1 end
vim.fn.maparg("<Space>bo", "n", false, true).callback()
vim.fn.confirm = confirm
assert(vim.api.nvim_get_current_buf() == current and vim.bo[current].buflisted)
assert(not vim.bo[other].buflisted)
assert(vim.bo[unsaved].buflisted and vim.bo[unsaved].modified)
assert(vim.api.nvim_buf_get_lines(unsaved, 0, -1, false)[1] == "keep changes")
assert(vim.api.nvim_buf_is_valid(unlisted))
for _, win in ipairs(windows) do assert(vim.api.nvim_win_is_valid(win)) end
print("Editor checks passed")
