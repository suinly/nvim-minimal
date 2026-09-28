-- Basics
vim.pack.add({ "https://github.com/nvim-mini/mini.basics" })
require("mini.basics").setup()

-- Comment
vim.pack.add({ "https://github.com/nvim-mini/mini.comment" })
require("mini.comment").setup({
  mappings = {
    comment = "<leader>/",
    comment_line = "<leader>/",
    comment_visual = "<leader>/",
    textobject = "<leader>/"
  }
})

-- Completion
vim.pack.add({ "https://github.com/nvim-mini/mini.completion" })
require("mini.completion").setup()

-- Keymap
vim.pack.add({ "https://github.com/nvim-mini/mini.keymap" })
require("mini.keymap").setup()

local map_multistep = require("mini.keymap").map_multistep

map_multistep("i", "<Tab>",   { "pmenu_next" })
map_multistep("i", "<S-Tab>", { "pmenu_prev" })
map_multistep("i", "<CR>",    { "pmenu_accept", "minipairs_cr" })
map_multistep("i", "<BS>",    { "minipairs_bs" })

local map_combo = require("mini.keymap").map_combo
local mode = { "i", "c", "x", "s" }
map_combo(mode, "jk", "<BS><BS><Esc>")
map_combo(mode, "kj", "<BS><BS><Esc>")

-- Pairs
vim.pack.add({ "https://github.com/nvim-mini/mini.pairs" })
require("mini.pairs").setup()

-- Surround
vim.pack.add({ "https://github.com/nvim-mini/mini.surround" })
require("mini.surround").setup()

-- Cmdline
vim.pack.add({ "https://github.com/nvim-mini/mini.cmdline" })
require("mini.cmdline").setup()

-- Tailspace
vim.pack.add({ "https://github.com/nvim-mini/mini.trailspace" })
require("mini.trailspace").setup()
