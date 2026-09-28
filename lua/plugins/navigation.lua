-- Buffer removal
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
require("mini.bufremove").setup()

-- Key hints (uses the already loaded mini.nvim)
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "z" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>f", desc = "+Find" },
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    clue.gen_clues.g(),
    clue.gen_clues.z(),
    clue.gen_clues.square_brackets(),
    clue.gen_clues.windows(),
  },
  window = { delay = 300, config = { width = "auto", border = "rounded" } },
})

-- Files
vim.pack.add({ "https://github.com/nvim-mini/mini.files" })
require("mini.files").setup({ windows = { preview = true, width_preview = 80 } })

-- Jump
vim.pack.add({ "https://github.com/nvim-mini/mini.jump" })
require("mini.jump").setup()

-- Pick
vim.pack.add({ "https://github.com/nvim-mini/mini.pick" })
require("mini.pick").setup({
  mappings = { move_down = "<C-j>", move_up = "<C-k>" },
})

-- Fuzzy
vim.pack.add({ "https://github.com/nvim-mini/mini.fuzzy" })
require("mini.fuzzy").setup()

-- Herdr
vim.pack.add({ "https://github.com/lmilojevicc/herdr-splits.nvim" })
require("herdr-splits").setup()
