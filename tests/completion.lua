-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/completion.lua")' '+qa!'
local function insert(keys)
  vim.cmd.enew()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt", false)
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local menu = "i<Cmd>lua vim.fn.complete(1, {'first', 'second'})<CR>"
local check_selection = "<Cmd>lua vim.g.first_selected = vim.fn.complete_info().selected; vim.g.before_accept = vim.api.nvim_get_current_line()<CR>"
assert(vim.deep_equal(insert(menu .. check_selection .. "<CR><Esc>"), { "first" }), "Enter must accept the first suggestion")
assert(vim.g.first_selected == 0, "First suggestion must be selected when the menu opens")
assert(vim.g.before_accept == "", "Selecting a suggestion must wait for acceptance before inserting it")
vim.bo.modified = false
assert(vim.deep_equal(insert(menu .. "<C-n><CR><Esc>"), { "second" }), "Enter must accept the selected suggestion")
vim.bo.modified = false
assert(vim.deep_equal(insert("ifirst<CR>second<Esc>"), { "first", "second" }), "Enter without completion must insert a newline")
vim.bo.modified = false
local paired = insert("i{<CR><Esc>")
assert(#paired == 3 and paired[1] == "{" and vim.trim(paired[2]) == "" and vim.trim(paired[3]) == "}", "Enter must preserve paired-bracket expansion")
vim.bo.modified = false
print("Completion Enter checks passed")
