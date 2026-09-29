vim.opt.relativenumber = true
vim.opt.signcolumn = "auto:1-2"
vim.opt.swapfile = false
vim.opt.scrolloff = 5
vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0

require("vim._core.ui2").enable({ msg = { targets = "msg" } })
require("modal")
