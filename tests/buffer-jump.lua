-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/buffer-jump.lua")' '+qa!'
for _, buf in ipairs(vim.api.nvim_list_bufs()) do vim.bo[buf].buflisted = false end
local first = vim.api.nvim_create_buf(true, false)
local second = vim.api.nvim_create_buf(true, false)
local unlisted = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(first)
local jump = vim.fn.maparg("<Space>bb", "n", false, true).callback
local format = MiniTabline.config.format
local getcharstr = vim.fn.getcharstr
MiniTabline.make_tabline_string()
local first_format, second_format = format(first, "first"), format(second, "second")
local unlisted_format = format(unlisted, "unlisted")
local ok, err = pcall(function()
  vim.fn.getcharstr = function()
    assert(format(first, "first"):find(" a first ", 1, true))
    assert(format(second, "second"):find(" s second ", 1, true))
    assert(format(unlisted, "unlisted") == unlisted_format)
    assert(vim.fn.strdisplaywidth(format(first, "first")) == vim.fn.strdisplaywidth(first_format), "Picking must preserve buffer width")
    assert(vim.fn.strdisplaywidth(format(second, "second")) == vim.fn.strdisplaywidth(second_format))
    local tabline = vim.api.nvim_eval_statusline(vim.o.tabline, { use_tabline = true }).str
    assert(tabline:find(" a ", 1, true) and tabline:find(" s ", 1, true), "Labels must appear in the rendered tabline")
    assert(MiniTabline.make_tabline_string():find("%#BufferJumpHint#s%#MiniTablineHidden#", 1, true), "Only the selection letter must use its highlight")
    return "s"
  end
  jump()
  assert(vim.api.nvim_get_current_buf() == second, "A label must switch to its buffer")
  assert(format(first, "first") == first_format, "Icons must return after choosing")
  assert(not MiniTabline.make_tabline_string():find("BufferJumpHint", 1, true), "Hint highlights must disappear after choosing")
  for _, key in ipairs({ "\27", "!" }) do
    vim.fn.getcharstr = function() return key end
    jump()
    assert(vim.api.nvim_get_current_buf() == second, "Cancelling must keep the current buffer")
    assert(format(second, "second") == second_format)
  end
  for _ = 1, 25 do vim.api.nvim_create_buf(true, false) end
  local calls = 0
  vim.fn.getcharstr = function()
    assert(format(first, "first"):find(" a first ", 1, true))
    assert(vim.fn.strdisplaywidth(format(first, "first")) == vim.fn.strdisplaywidth(first_format), "Multi-letter selection must preserve width")
    if calls == 1 then assert(format(second, "second"):find(" s second ", 1, true), "Second selection step must show the next letter") end
    calls = calls + 1
    return "a"
  end
  jump()
  assert(calls == 2 and vim.api.nvim_get_current_buf() == first, "Two-letter labels must select the right buffer")
  vim.fn.getcharstr = function() error("Keyboard interrupt") end
  jump()
  assert(format(first, "first") == first_format, "Interrupted selection must restore icons")
end)
vim.fn.getcharstr = getcharstr
assert(ok, err)
print("Buffer label jump checks passed")
