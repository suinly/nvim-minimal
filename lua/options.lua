vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.scrolloff = 5
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0

require("vim._core.ui2").enable({ msg = { targets = "msg" } })
